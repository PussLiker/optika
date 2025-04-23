using Optika.API.Repositories;
using Optika.API.Services;
using Optika.API.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Регистрируем контроллеры (с автоматической маршрутизацией)
builder.Services.AddControllers();

// Swagger — для тестирования API через UI
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Регистрируем контекст EF Core и строку подключения к PostgreSQL
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// Подключаем слои репозиториев и сервисов
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<IProductService, ProductService>();

builder.Services.AddScoped(typeof(IRepository<>), typeof(GenericRepository<>));
builder.Services.AddScoped(typeof(IService<,>), typeof(GenericService<,>));

var app = builder.Build();

// Swagger включается только в режиме разработки
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// HTTPS редирект (http → https)
app.UseHttpsRedirection();

// Middleware авторизации (пока что бесполезно, если нет аутентификации)
app.UseAuthorization();

// Маршрутизация контроллеров
app.MapControllers();

// Регистрируем маппинги (например, AutoMapper)
Optika.API.Mapping.MappingConfig.RegisterMappings();

app.Run();

