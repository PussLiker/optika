using Microsoft.AspNetCore.Mvc;
using Optika.API.DTOs;
using Optika.API.Entities;
using Optika.API.Services;
using Mapster;

namespace Optika.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ReviewController : ControllerBase
    {
        private readonly IService<Review, ReviewCreateDto> _reviewService;

        public ReviewController(IService<Review, ReviewCreateDto> reviewService)
        {
            _reviewService = reviewService;
        }

        // 1. Получить все отзывы
        [HttpGet]
        public async Task<ActionResult<IEnumerable<ReviewDto>>> GetAllAsync()
        {
            var reviews = await _reviewService.GetAllAsync();
            return Ok(reviews);
        }

        // 2. Получить отзыв по ID
        [HttpGet("{id}", Name = "GetReviewById")]
        public async Task<ActionResult<ReviewDto>> GetByIdAsync(int id)
        {
            var review = await _reviewService.GetByIdAsync(id);
            if (review == null)
                return NotFound();

            var dto = review.Adapt<ReviewDto>();
            return Ok(dto);
        }

        // 3. Создать новый отзыв
        [HttpPost]
        public async Task<ActionResult<ReviewDto>> CreateAsync([FromBody] ReviewCreateDto createDto)
        {
            var created = await _reviewService.CreateAsync(createDto);
            var dto = created.Adapt<ReviewDto>();

            return CreatedAtRoute(
                routeName: "GetReviewById",
                routeValues: new { id = created.Id },
                value: dto
            );
        }

        // 4. Обновить отзыв
        [HttpPut("{id}")]
        public async Task<ActionResult<ReviewDto>> UpdateAsync(int id, [FromBody] ReviewCreateDto updateDto)
        {
            var updated = await _reviewService.UpdateAsync(id, updateDto);
            if (updated == null)
                return NotFound();

            var dto = updated.Adapt<ReviewDto>();
            return Ok(dto);
        }

        // 5. Удалить отзыв
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(int id)
        {
            try
            {
                await _reviewService.DeleteAsync(id);
                return NoContent();
            }
            catch (ArgumentException)
            {
                return NotFound();
            }
        }
    }
}
