using Microsoft.AspNetCore.Mvc;
using Optika.API.DTOs;
using Optika.API.Entities;
using Optika.API.Services;
using Mapster;

namespace Optika.API.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly IService<User, UserCreateDto> _userService;

        public UserController(IService<User, UserCreateDto> userService)
        {
            _userService = userService;
        }

        // 1. Получить всех пользователей
        [HttpGet]
        public async Task<ActionResult<IEnumerable<UserDto>>> GetAllAsync()
        {
            var users = await _userService.GetAllAsync();
            return Ok(users);
        }

        // 2. Получить пользователя по ID
        [HttpGet("{id}", Name = "GetUserById")]
        public async Task<ActionResult<UserDto>> GetByIdAsync(int id)
        {
            var user = await _userService.GetByIdAsync(id);
            if (user == null)
                return NotFound();

            var dto = user.Adapt<UserDto>();
            return Ok(dto);
        }

        // 3. Создать нового пользователя
        [HttpPost]
        public async Task<ActionResult<UserDto>> CreateAsync([FromBody] UserCreateDto createDto)
        {
            var created = await _userService.CreateAsync(createDto);
            var dto = created.Adapt<UserDto>();

            return CreatedAtRoute(
                routeName: "GetUserById",
                routeValues: new { id = created.Id },
                value: dto
            );
        }

        // 4. Обновить пользователя
        [HttpPut("{id}")]
        public async Task<ActionResult<UserDto>> UpdateAsync(int id, [FromBody] UserCreateDto updateDto)
        {
            var updated = await _userService.UpdateAsync(id, updateDto);
            if (updated == null)
                return NotFound();

            var dto = updated.Adapt<UserDto>();
            return Ok(dto);
        }

        // 5. Удалить пользователя
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteAsync(int id)
        {
            try
            {
                await _userService.DeleteAsync(id);
                return NoContent();
            }
            catch (ArgumentException)
            {
                return NotFound();
            }
        }
    }
}
