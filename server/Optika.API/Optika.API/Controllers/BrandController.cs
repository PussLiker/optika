using Microsoft.AspNetCore.Mvc;
using Optika.API.DTOs;
using Optika.API.Entities;
using Optika.API.Services;
using Mapster;

namespace Optika.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BrandController : ControllerBase
    {
        private readonly IService<Brand, BrandCreateDto> _brandService;

        public BrandController(IService<Brand, BrandCreateDto> brandService)
        {
            _brandService = brandService;
        }

        // 1. Получить все бренды
        [HttpGet]
        public async Task<ActionResult<IEnumerable<BrandDto>>> GetAllAsync()
        {
            var brands = await _brandService.GetAllAsync();
            return Ok(brands);
        }

        // 2. Получить бренд по ID — даём ему имя маршрута "GetBrandById"
        [HttpGet("{id}", Name = "GetBrandById")]
        public async Task<ActionResult<BrandDto>> GetByIdAsync(int id)
        {
            var brand = await _brandService.GetByIdAsync(id);
            if (brand == null)
                return NotFound();

            // Превращаем сущность в DTO (можно через Mapster)
            var dto = brand.Adapt<BrandDto>();
            return Ok(dto);
        }

        // 3. Создать новый бренд
        [HttpPost]
        public async Task<ActionResult<BrandDto>> CreateAsync([FromBody] BrandCreateDto createDto)
        {
            var created = await _brandService.CreateAsync(createDto);

            // Преобразуем в DTO
            var dto = created.Adapt<BrandDto>();

            // Используем именованный маршрут для генерации Location
            return CreatedAtRoute(
                routeName: "GetBrandById",
                routeValues: new { id = created.Id },
                value: dto
            );
        }

        // 4. Обновить бренд
        [HttpPut("{id}")]
        public async Task<ActionResult<BrandDto>> UpdateAsync(int id, [FromBody] BrandCreateDto updateDto)
        {
            var updated = await _brandService.UpdateAsync(id, updateDto);
            if (updated == null)
                return NotFound();

            var dto = updated.Adapt<BrandDto>();
            return Ok(dto);
        }

        // 5. Удалить бренд
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(int id)
        {
            try
            {
                await _brandService.DeleteAsync(id);
                return NoContent();
            }
            catch (ArgumentException)
            {
                return NotFound();
            }
        }
    }
}
