using Mapster;
using Optika.API.Repositories;

namespace Optika.API.Services
{
    public class GenericService<T, TDto> : IService<T, TDto>
        where T : class, new()
        where TDto : class
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

        public async Task<T> CreateAsync(TDto dto)
        {
            var entity = dto.Adapt<T>();
            return await _repository.AddAsync(entity);
        }

        public async Task<T> UpdateAsync(int id, TDto dto)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
            {
                throw new ArgumentException($"Entity with id {id} not found.");
            }

            entity = dto.Adapt(entity);
            typeof(T).GetProperty("Id")?.SetValue(entity, id);

            return await _repository.UpdateAsync(entity);
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
            {
                throw new ArgumentException($"Entity with id {id} not found.");
            }

            await _repository.DeleteAsync(id);
        }
    }
}
