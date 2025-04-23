using Mapster;
using Optika.API.DTOs;
using Optika.API.Entities;

namespace Optika.API.Mapping
{
    public static class MappingConfig
    {
        public static void RegisterMappings()
        {
            TypeAdapterConfig<UserCreateDto, User>.NewConfig();
            TypeAdapterConfig<BrandCreateDto, Brand>.NewConfig();
            TypeAdapterConfig<CategoryCreateDto, Category>.NewConfig();
            TypeAdapterConfig<ProductCreateDto, Product>.NewConfig();
            TypeAdapterConfig<OrderCreateDto, Order>.NewConfig();
            TypeAdapterConfig<OrderItemCreateDto, OrderItem>.NewConfig();
            TypeAdapterConfig<ReviewCreateDto, Review>.NewConfig();
        }
    }
}
