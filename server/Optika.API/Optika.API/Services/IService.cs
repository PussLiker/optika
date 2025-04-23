namespace Optika.API.Services
{
    public interface IService<T, TCreateDto>
    {
        Task<IEnumerable<T>> GetAllAsync();
        Task<T?> GetByIdAsync(int id);
        Task<T> CreateAsync(TCreateDto dto);
        Task<T> UpdateAsync(int id, TCreateDto dto);
        Task DeleteAsync(int id);
    }
}
