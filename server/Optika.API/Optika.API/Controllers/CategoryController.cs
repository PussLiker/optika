using Microsoft.AspNetCore.Mvc;
using Optika.API.DTOs;
using Optika.API.Entities;
using Optika.API.Services;
using Mapster;

namespace Optika.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoryController : ControllerBase
    {
        private readonly IService<Category, CategoryCreateDto> _categoryService;

        public CategoryController(IService<Category, CategoryCreateDto> categoryService)
        {
            _categoryService = categoryService;
        }

        // 1. Получить все категории
        [HttpGet]
        public async Task<ActionResult<IEnumerable<CategoryDto>>> GetAllAsync()
        {
            var categories = await _categoryService.GetAllAsync();
            return Ok(categories);
        }

        // 2. Получить категорию по ID
        [HttpGet("{id}", Name = "GetCategoryById")]
        public async Task<ActionResult<CategoryDto>> GetByIdAsync(int id)
        {
            var category = await _categoryService.GetByIdAsync(id);
            if (category == null)
                return NotFound();

            var dto = category.Adapt<CategoryDto>();
            return Ok(dto);
        }

        // 3. Создать новую категорию
        [HttpPost]
        public async Task<ActionResult<CategoryDto>> CreateAsync([FromBody] CategoryCreateDto createDto)
        {
            var created = await _categoryService.CreateAsync(createDto);
            var dto = created.Adapt<CategoryDto>();

            return CreatedAtRoute(
                routeName: "GetCategoryById",
                routeValues: new { id = created.Id },
                value: dto
            );
        }

        // 4. Обновить категорию
        [HttpPut("{id}")]
        public async Task<ActionResult<CategoryDto>> UpdateAsync(int id, [FromBody] CategoryCreateDto updateDto)
        {
            var updated = await _categoryService.UpdateAsync(id, updateDto);
            if (updated == null)
                return NotFound();

            var dto = updated.Adapt<CategoryDto>();
            return Ok(dto);
        }

        // 5. Удалить категорию
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(int id)
        {
            try
            {
                await _categoryService.DeleteAsync(id);
                return NoContent();
            }
            catch (ArgumentException)
            {
                return NotFound();
            }
        }
    }
}
