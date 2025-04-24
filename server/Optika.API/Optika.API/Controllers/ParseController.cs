using Microsoft.AspNetCore.Mvc;
using Optika.API.Services;

[ApiController]
[Route("api/[controller]")]
public class ProductsParserController : ControllerBase
{
    private readonly IProductParserService _parserService;
    private readonly ILogger<ProductsParserController> _logger;

    public ProductsParserController(
        IProductParserService parserService,
        ILogger<ProductsParserController> logger)
    {
        _parserService = parserService;
        _logger = logger;
    }

    [HttpPost("parse")]
    public async Task<IActionResult> ParseProducts([FromQuery] int count = 10)
    {
        try
        {
            await _parserService.ParseProductsAsync(count);
            return Ok($"Успешно спаршено {count} товаров из каждой категории");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Ошибка при парсинге товаров");
            return StatusCode(500, "Произошла ошибка при обработке запроса");
        }
    }
}