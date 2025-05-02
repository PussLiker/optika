// Services/IAuthService.cs
using Optika.API.DTOs;

namespace Optika.API.Services
{
    public interface IAuthService
    {
        Task<AuthResponseDto?> LoginAsync(string email, string password);
    }
}
