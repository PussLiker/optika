using Microsoft.AspNetCore.Mvc;
using Optika.API.DTOs;
using Optika.API.Entities;
using Optika.API.Services;
using Mapster;

namespace Optika.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class OrderItemController : ControllerBase
    {
        private readonly IService<OrderItem, OrderItemCreateDto> _orderItemService;

        public OrderItemController(IService<OrderItem, OrderItemCreateDto> orderItemService)
        {
            _orderItemService = orderItemService;
        }

        // 1. Получить все элементы заказов
        [HttpGet]
        public async Task<ActionResult<IEnumerable<OrderItemDto>>> GetAllAsync()
        {
            var orderItems = await _orderItemService.GetAllAsync();
            return Ok(orderItems);
        }

        // 2. Получить элемент заказа по ID
        [HttpGet("{id}", Name = "GetOrderItemById")]
        public async Task<ActionResult<OrderItemDto>> GetByIdAsync(int id)
        {
            var orderItem = await _orderItemService.GetByIdAsync(id);
            if (orderItem == null)
                return NotFound();

            var dto = orderItem.Adapt<OrderItemDto>();
            return Ok(dto);
        }

        // 3. Создать новый элемент заказа
        [HttpPost]
        public async Task<ActionResult<OrderItemDto>> CreateAsync([FromBody] OrderItemCreateDto createDto)
        {
            var created = await _orderItemService.CreateAsync(createDto);
            var dto = created.Adapt<OrderItemDto>();

            return CreatedAtRoute(
                routeName: "GetOrderItemById",
                routeValues: new { id = created.Id },
                value: dto
            );
        }

        // 4. Обновить элемент заказа
        [HttpPut("{id}")]
        public async Task<ActionResult<OrderItemDto>> UpdateAsync(int id, [FromBody] OrderItemCreateDto updateDto)
        {
            var updated = await _orderItemService.UpdateAsync(id, updateDto);
            if (updated == null)
                return NotFound();

            var dto = updated.Adapt<OrderItemDto>();
            return Ok(dto);
        }

        // 5. Удалить элемент заказа
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(int id)
        {
            try
            {
                await _orderItemService.DeleteAsync(id);
                return NoContent();
            }
            catch (ArgumentException)
            {
                return NotFound();
            }
        }
    }
}
