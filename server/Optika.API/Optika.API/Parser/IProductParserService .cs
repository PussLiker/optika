namespace Optika.API.Services
{
    public interface IProductParserService
    {
        Task ParseProductsAsync(int count);
    }
}
