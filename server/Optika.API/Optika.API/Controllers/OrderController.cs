using Microsoft.AspNetCore.Mvc;
using Optika.API.DTOs;
using Optika.API.Entities;
using Optika.API.Services;
using Mapster;

namespace Optika.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OrderController : ControllerBase
    {
        private readonly IOrderService _orderService;

        public OrderController(IOrderService orderService)
        {
            _orderService = orderService;
        }

        // 1. Получить все заказы
        [HttpGet]
        public async Task<ActionResult<IEnumerable<OrderDto>>> GetAllAsync()
        {
            var orders = await _orderService.GetAllAsync();
            return Ok(orders);
        }

        // 2. Получить заказ по ID
        [HttpGet("{id}", Name = "GetOrderById")]
        public async Task<ActionResult<OrderDto>> GetByIdAsync(int id)
        {
            var order = await _orderService.GetByIdAsync(id);
            if (order == null)
                return NotFound();

            var dto = order.Adapt<OrderDto>();
            return Ok(dto);
        }

        // 3. Создать новый заказ
        [HttpPost]
        public async Task<ActionResult<OrderDto>> CreateAsync([FromBody] OrderCreateDto createDto)
        {
            var userId = int.Parse(User.FindFirst("id")!.Value); // достаём ID из токена

            var created = await _orderService.CreateAsync(userId, createDto);
            var dto = created.Adapt<OrderDto>();

            return CreatedAtRoute(
                routeName: "GetOrderById",
                routeValues: new { id = created.Id },
                value: dto
            );
        }

        // 4. Обновить заказ
        [HttpPut("{id}")]
        public async Task<ActionResult<OrderDto>> UpdateAsync(int id, [FromBody] OrderCreateDto updateDto)
        {
            var updated = await _orderService.UpdateAsync(id, updateDto);
            if (updated == null)
                return NotFound();

            var dto = updated.Adapt<OrderDto>();
            return Ok(dto);
        }

        // 5. Удалить заказ
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(int id)
        {
            try
            {
                await _orderService.DeleteAsync(id);
                return NoContent();
            }
            catch (ArgumentException)
            {
                return NotFound();
            }
        }
    }
}
