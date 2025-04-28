using HtmlAgilityPack;
using Microsoft.Extensions.Logging;
using Optika.API.Entities;
using Optika.API.Data;
using System.Globalization;
using Microsoft.EntityFrameworkCore;

namespace Optika.API.Services
{
    public class ProductParserService : IProductParserService
    {
        private readonly AppDbContext _db;
        private readonly ILogger<ProductParserService> _logger;
        private readonly HttpClient _httpClient;
        private readonly Dictionary<string, Brand> _brandsCache = new();

        private readonly List<(string CategoryName, string Url)> _categorySources = new()
        {
            ("Оправы", "https://www.optic-city.ru/ochki_s_dioptrijami/katalog_oprav/"),
            ("Контактные линзы", "https://www.optic-city.ru/kontaktnye_linzy/odnodnevnye_linzy/"),
            ("Солнцезащитные очки", "https://www.optic-city.ru/solntsezaschitnye_ochki/")
        };

        public ProductParserService(
            AppDbContext db,
            ILogger<ProductParserService> logger,
            IHttpClientFactory httpClientFactory)
        {
            _db = db;
            _logger = logger;
            _httpClient = httpClientFactory.CreateClient();
            _httpClient.DefaultRequestHeaders.UserAgent.ParseAdd("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36");
        }

        public async Task ParseProductsAsync(int count)
        {
            foreach (var (categoryName, url) in _categorySources)
            {
                try
                {
                    var category = await _db.Categories
                        .FirstOrDefaultAsync(c => c.Name == categoryName);

                    if (category == null)
                    {
                        _logger.LogWarning("Категория '{CategoryName}' не найдена", categoryName);
                        continue;
                    }

                    var doc = await LoadDocumentAsync(url);
                    if (doc == null) continue;

                    var productNodes = GetProductNodes(doc, categoryName);
                    if (productNodes == null || !productNodes.Any())
                    {
                        _logger.LogWarning("Товары не найдены на {Url}", url);
                        continue;
                    }

                    await ProcessNodesAsync(productNodes.Take(count), category.Id);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Ошибка при парсинге категории '{CategoryName}'", categoryName);
                }
            }
        }

        private List<HtmlNode> GetProductNodes(HtmlDocument doc, string categoryName)
        {
            return categoryName switch
            {
                "Контактные линзы" => doc.DocumentNode
                    .SelectNodes("//div[contains(@class, 'col-') and contains(@class, 'col-xl-4')]")?
                    .Where(n => n.InnerHtml.Contains("product-card") && n.InnerHtml.Contains("linzy"))
                    .ToList(),

                _ => doc.DocumentNode
                    .SelectNodes("//div[contains(@class, 'product ') and contains(@class, 'col-')]")?
                    .ToList()
            };
        }

        private async Task ProcessNodesAsync(IEnumerable<HtmlNode> nodes, int categoryId)
        {
            foreach (var node in nodes)
            {
                try
                {
                    var product = await ParseProductNode(node, categoryId);
                    if (product == null) continue;

                    // Проверяем дубликаты по названию+бренду ИЛИ по изображению
                    bool exists = await _db.Products.AnyAsync(p =>
                        (p.Name == product.Name && p.BrandId == product.BrandId) ||
                        (!string.IsNullOrEmpty(product.ImageUrl) &&
                         !string.IsNullOrEmpty(p.ImageUrl) &&
                         p.ImageUrl == product.ImageUrl));

                    if (!exists)
                    {
                        await _db.Products.AddAsync(product);
                        _logger.LogInformation("Добавлен товар: {Name}", product.Name);
                    }
                    else
                    {
                        _logger.LogInformation("Товар {Name} уже существует, пропускаем", product.Name);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Ошибка при обработке товара");
                }
            }
            await _db.SaveChangesAsync();
        }
        private async Task<bool> ProductWithImageExistsAsync(string imageUrl)
        {
            if (string.IsNullOrEmpty(imageUrl))
                return false;

            try
            {
                var imageBytes = await _httpClient.GetByteArrayAsync(imageUrl);
                var imageHash = BitConverter.ToString(
                    System.Security.Cryptography.MD5.HashData(imageBytes)
                ).Replace("-", "").ToLower();

                var extension = Path.GetExtension(imageUrl)?.Split('?').First() ?? ".jpg";
                var fileName = $"{imageHash}{extension}";

                return await _db.Products.AnyAsync(p => p.ImageUrl == $"/images/{fileName}");
            }
            catch
            {
                return false;
            }
        }
        private async Task<Products> ParseProductNode(HtmlNode node, int categoryId)
        {
            var isLensCategory = categoryId == _db.Categories.First(c => c.Name == "Контактные линзы").Id;

            return isLensCategory
                ? await ParseLensNode(node, categoryId)
                : await ParseGlassesNode(node, categoryId);
        }

        private async Task<Products> ParseGlassesNode(HtmlNode node, int categoryId)
        {
            var linkNode = node.SelectSingleNode(".//a[contains(@class, 'product-card')]");
            if (linkNode == null) return null;

            var relativeUrl = linkNode.GetAttributeValue("href", "");
            var productUrl = $"https://www.optic-city.ru{relativeUrl.TrimStart('/')}";

            var titleNode = linkNode.SelectSingleNode(".//div[contains(@class, 'product-card__title')]");
            var brandName = titleNode?.SelectSingleNode(".//span[contains(@class, 'product-card__name')]")?.InnerText.Trim();
            var modelNumber = titleNode?.SelectSingleNode(".//span[contains(@class, 'product-card__id')]")?.InnerText.Trim();

            var priceNode = linkNode.SelectSingleNode(".//span[contains(@class, 'product-card__price')]");
            var imgNode = linkNode.SelectSingleNode(".//img[contains(@class, 'product-card__photo--current')]");

            if (string.IsNullOrEmpty(modelNumber) || priceNode == null)
            {
                _logger.LogWarning("Не найдены обязательные данные: модель {Model} или цена", modelNumber);
                return null;
            }

            var priceText = priceNode.InnerText.Replace("Р", "").Replace(" ", "").Trim();
            if (!decimal.TryParse(priceText, NumberStyles.Any, CultureInfo.InvariantCulture, out var price))
            {
                _logger.LogWarning("Неверный формат цены: {PriceText}", priceText);
                return null;
            }

            var brand = GetOrCreateBrand(brandName ?? "Unknown");
            var savedImagePath = await DownloadAndSaveImageAsync(
                imgNode?.GetAttributeValue("src", null),
                modelNumber
            );

            return new Products
            {
                Name = modelNumber,
                Description = productUrl,
                Price = price,
                ImageUrl = savedImagePath,
                BrandId = brand.Id,
                CategoryId = categoryId,
                CreatedAt = DateTime.UtcNow
            };
        }

        private async Task<Products> ParseLensNode(HtmlNode node, int categoryId)
        {
            try
            {
                var linkNode = node.SelectSingleNode(".//a[contains(@class, 'product-card')]");
                if (linkNode == null)
                {
                    _logger.LogWarning("Не найдена ссылка на товар");
                    return null;
                }

                var relativeUrl = linkNode.GetAttributeValue("href", "");
                var productUrl = $"https://www.optic-city.ru{relativeUrl.TrimStart('/')}";

                var titleNode = linkNode.SelectSingleNode(".//div[contains(@class, 'product-card__title')]");
                var modelName = titleNode?.SelectSingleNode(".//span[contains(@class, 'product-card__name')]")?.InnerText.Trim();
                var brandName = titleNode?.SelectSingleNode(".//span[contains(@class, 'product-card__id')]")?.InnerText.Trim();

                if (string.IsNullOrEmpty(modelName))
                {
                    _logger.LogWarning("Не найдено название модели");
                    return null;
                }

                var priceNode = linkNode.SelectSingleNode(".//span[contains(@class, 'product-card__prices--current')]");
                var priceText = priceNode?.InnerText?
                    .Replace("р", "")
                    .Replace("Р", "")
                    .Replace(" ", "")
                    .Trim();

                if (!decimal.TryParse(priceText, NumberStyles.Any, CultureInfo.InvariantCulture, out var price))
                {
                    _logger.LogWarning("Не удалось распарсить цену: {PriceText}", priceText);
                    return null;
                }

                var imgNode = linkNode.SelectSingleNode(".//img[contains(@class, 'product-card__photo--current')]");
                var savedImagePath = await DownloadAndSaveImageAsync(
                    imgNode?.GetAttributeValue("src", null),
                    modelName
                );

                var brand = GetOrCreateBrand(brandName ?? "Unknown");

                return new Products
                {
                    Name = modelName,
                    Description = productUrl,
                    Price = price,
                    ImageUrl = savedImagePath,
                    BrandId = brand.Id,
                    CategoryId = categoryId,
                    CreatedAt = DateTime.UtcNow
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка парсинга линз");
                return null;
            }
        }

        private async Task<HtmlDocument> LoadDocumentAsync(string url)
        {
            try
            {
                var html = await _httpClient.GetStringAsync(url);
                var doc = new HtmlDocument();
                doc.LoadHtml(html);
                return doc;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка загрузки страницы {Url}", url);
                return null;
            }
        }

        private Brand GetOrCreateBrand(string brandName)
        {
            if (_brandsCache.TryGetValue(brandName, out var cachedBrand))
                return cachedBrand;

            var brand = _db.Brands.FirstOrDefault(b => b.Name == brandName);
            if (brand == null)
            {
                brand = new Brand { Name = brandName };
                _db.Brands.Add(brand);
                _db.SaveChanges();
            }

            _brandsCache[brandName] = brand;
            return brand;
        }

        private async Task<string?> DownloadAndSaveImageAsync(string? imageUrl, string productName)
        {
            if (string.IsNullOrEmpty(imageUrl))
                return null;

            try
            {
                // Получаем хеш изображения для уникального имени файла
                var imageBytes = await _httpClient.GetByteArrayAsync(imageUrl);
                var imageHash = BitConverter.ToString(
                    System.Security.Cryptography.MD5.HashData(imageBytes)
                ).Replace("-", "").ToLower();

                var extension = Path.GetExtension(imageUrl)?.Split('?').First() ?? ".jpg";
                var fileName = $"{imageHash}{extension}";
                var savePath = Path.Combine("wwwroot", "images", fileName);

                // Если файл уже существует - возвращаем существующий путь
                if (File.Exists(savePath))
                {
                    return $"/images/{fileName}";
                }

                // Сохраняем новое изображение
                Directory.CreateDirectory(Path.Combine("wwwroot", "images"));
                await File.WriteAllBytesAsync(savePath, imageBytes);

                return $"/images/{fileName}";
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка загрузки изображения для товара {ProductName}", productName);
                return null;
            }
        }
    }
}