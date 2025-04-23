using Optika.API.Entities;

namespace Optika.API.Repositories
{
    public interface IProductRepository
    {
        Task<Product> AddAsync(Product product);
        Task<IEnumerable<Product>> GetAllAsync();
        Task<Product> GetByIdAsync(int id); 
        Task SaveAsync(Product product);
        Task DeleteAsync(int id);
    }
}
