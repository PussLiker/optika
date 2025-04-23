using Mapster;
using Optika.API.Repositories;

namespace Optika.API.Services
{
    public class GenericService<T, TCreateDto> : IService<T, TCreateDto> where T : class
    {
        private readonly IRepository<T> _repository;

        public GenericService(IRepository<T> repository)
        {
            _repository = repository;
        }

        public async Task<IEnumerable<T>> GetAllAsync()
        {
            return await _repository.GetAllAsync();
        }

        public async Task<T?> GetByIdAsync(int id)
        {
            return await _repository.GetByIdAsync(id);
        }

        public async Task<T> CreateAsync(TCreateDto dto)
        {
            var entity = dto.Adapt<T>();
            return await _repository.AddAsync(entity);
        }

        public async Task<T> UpdateAsync(int id, TCreateDto dto)
        {
            var entity = dto.Adapt<T>();
            typeof(T).GetProperty("Id")?.SetValue(entity, id);
            return await _repository.UpdateAsync(entity);
        }

        public async Task DeleteAsync(int id)
        {
            await _repository.DeleteAsync(id);
        }
    }
}
