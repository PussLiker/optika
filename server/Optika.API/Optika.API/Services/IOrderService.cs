using Optika.API.DTOs;
using Optika.API.Entities;

namespace Optika.API.Services
{
    public interface IOrderService
    {
        Task<IEnumerable<Order>> GetAllAsync();
        Task<Order?> GetByIdAsync(int id);
        Task<Order> CreateAsync(int userId, OrderCreateDto dto);
        Task<Order?> UpdateAsync(int id, OrderCreateDto dto);
        Task DeleteAsync(int id);
    }
}
