using Mapster;
using Optika.API.DTOs;
using Optika.API.Entities;

namespace Optika.API.Mapping
{
    public static class MappingConfig
    {
        public static void RegisterMappings()
        {
            TypeAdapterConfig<ProductCreateDto, Product>.NewConfig()
                .Map(dest => dest.IsActive, src => true)
                .Ignore(dest => dest.Id)
                .Ignore(dest => dest.CreatedAt);
        }
    }
}
