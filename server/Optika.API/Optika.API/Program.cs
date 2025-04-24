using Optika.API.Repositories;
using Optika.API.Services;
using Optika.API.Data;
using Microsoft.EntityFrameworkCore;
using Optika.API.DTOs;
using Optika.API.Entities;
using Optika.API.Mapping;

var builder = WebApplication.CreateBuilder(args);

// Регистрируем контроллеры (с автоматической маршрутизацией)
builder.Services.AddControllers();

// Парсер брендов
// Добавьте эти строки в конфигурацию сервисов
builder.Services.AddHttpClient();
builder.Services.AddScoped<IProductParserService, ProductParserService>();

// Swagger — для тестирования API через UI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Регистрируем контекст EF Core и строку подключения к PostgreSQL
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Подключаем слои репозиториев и сервисов
builder.Services.AddScoped<IService<Products, ProductCreateDto>, GenericService<Products, ProductCreateDto>>();
builder.Services.AddScoped<IService<Category, CategoryCreateDto>, GenericService<Category, CategoryCreateDto>>();
builder.Services.AddScoped<IService<Brand, BrandCreateDto>, GenericService<Brand, BrandCreateDto>>();
builder.Services.AddScoped<IService<User, UserCreateDto>, GenericService<User, UserCreateDto>>();
builder.Services.AddScoped<IService<Review, ReviewCreateDto>, GenericService<Review, ReviewCreateDto>>();
builder.Services.AddScoped<IService<OrderItem, OrderItemCreateDto>, GenericService<OrderItem, OrderItemCreateDto>>();
builder.Services.AddScoped<IService<Order, OrderCreateDto>, GenericService<Order, OrderCreateDto>>();


builder.Services.AddScoped(typeof(IRepository<>), typeof(GenericRepository<>));
builder.Services.AddScoped(typeof(IService<,>), typeof(GenericService<,>));





var app = builder.Build();

// Swagger включается только в режиме разработки
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
// Получаем scope для DbContext
using var scope = app.Services.CreateScope();
var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();



// регистрация маппинга
MappingConfig.RegisterMappings();

// HTTPS редирект (http → https)
app.UseHttpsRedirection();

// Middleware авторизации (пока что бесполезно, если нет аутентификации)
app.UseAuthorization();

// Маршрутизация контроллеров
app.MapControllers();

// Регистрируем маппинги (например, AutoMapper)
Optika.API.Mapping.MappingConfig.RegisterMappings();

app.Run();

