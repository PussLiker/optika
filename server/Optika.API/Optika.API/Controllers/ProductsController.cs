using Microsoft.AspNetCore.Mvc;
using Optika.API.DTOs;
using Optika.API.Entities;
using Optika.API.Services;
using Mapster;

namespace Optika.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductController : ControllerBase
    {
        private readonly IService<Product, ProductCreateDto> _productService;

        public ProductController(IService<Product, ProductCreateDto> productService)
        {
            _productService = productService;
        }

        // 1. Получить все продукты
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ProductDto>>> GetAllAsync()
        {
            var products = await _productService.GetAllAsync();
            return Ok(products);
        }

        // 2. Получить продукт по ID
        [HttpGet("{id}", Name = "GetProductById")]
        public async Task<ActionResult<ProductDto>> GetByIdAsync(int id)
        {
            var product = await _productService.GetByIdAsync(id);
            if (product == null)
                return NotFound();

            var dto = product.Adapt<ProductDto>();
            return Ok(dto);
        }

        // 3. Создать новый продукт
        [HttpPost]
        public async Task<ActionResult<ProductDto>> CreateAsync([FromBody] ProductCreateDto createDto)
        {
            var created = await _productService.CreateAsync(createDto);
            var dto = created.Adapt<ProductDto>();

            return CreatedAtRoute(
                routeName: "GetProductById",
                routeValues: new { id = created.Id },
                value: dto
            );
        }

        // 4. Обновить продукт
        [HttpPut("{id}")]
        public async Task<ActionResult<ProductDto>> UpdateAsync(int id, [FromBody] ProductCreateDto updateDto)
        {
            var updated = await _productService.UpdateAsync(id, updateDto);
            if (updated == null)
                return NotFound();

            var dto = updated.Adapt<ProductDto>();
            return Ok(dto);
        }

        // 5. Удалить продукт
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(int id)
        {
            try
            {
                await _productService.DeleteAsync(id);
                return NoContent();
            }
            catch (ArgumentException)
            {
                return NotFound();
            }
        }
    }
}
