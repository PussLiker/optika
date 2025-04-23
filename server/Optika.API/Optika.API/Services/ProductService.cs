using Mapster;
using Optika.API.DTOs;
using Optika.API.Entities;
using Optika.API.Repositories;

namespace Optika.API.Services
{
    public class ProductService : IProductService
    {
        private readonly IProductRepository _repository;

        public ProductService(IProductRepository repository)
        {
            _repository = repository;
        }

        public async Task<Product> CreateAsync(ProductCreateDto dto)
        {
            var entity = dto.Adapt<Product>();
            return await _repository.AddAsync(entity);
        }

        public async Task<IEnumerable<Product>> GetAllAsync()
        {
            return await _repository.GetAllAsync();
        }

        public async Task<Product> GetByIdAsync(int id)
        {
            var product = await _repository.GetByIdAsync(id);
            if (product == null)
            { throw new ArgumentException("Product not found"); }

            return product;
        }

        public async Task<Product> UpdateAsync(int id, ProductCreateDto dto)
        {
            var product = await _repository.GetByIdAsync(id);
            if (product == null)
                throw new ArgumentException("Product not found");

            product.Name = dto.Name;
            product.Description = dto.Description;
            product.Price = dto.Price;
            product.ImageUrl = dto.ImageUrl;

            await _repository.SaveAsync(product);

            return product;
        }
        public async Task DeleteAsync(int id)
        {
            var product = await _repository.GetByIdAsync(id);
            if (product == null)
                throw new ArgumentException("Product not found");

            await _repository.DeleteAsync(id);
        }
    }
}
