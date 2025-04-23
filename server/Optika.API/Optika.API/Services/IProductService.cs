using Optika.API.DTOs;
using Optika.API.Entities;

namespace Optika.API.Services
{
    public interface IProductService
    {
        Task<Product> CreateAsync(ProductCreateDto dto);
        Task<IEnumerable<Product>> GetAllAsync();
        Task<Product> UpdateAsync(int id, ProductCreateDto dto);
        Task<Product> GetByIdAsync(int id);
        Task DeleteAsync(int id);
    }
}
