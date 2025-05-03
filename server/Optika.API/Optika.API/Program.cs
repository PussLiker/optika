using Optika.API.Repositories;
using Optika.API.Services;
using Optika.API.Data;
using Microsoft.EntityFrameworkCore;
using Optika.API.DTOs;
using Optika.API.Entities;
using Optika.API.Mapping;
using Microsoft.IdentityModel.Tokens;
using System.Text;

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
builder.Services.AddScoped<IService<OrderItem, OrderItemCreateDto>, GenericService<OrderItem, OrderItemCreateDto>>();
builder.Services.AddScoped<IService<Order, OrderCreateDto>, GenericService<Order, OrderCreateDto>>();


builder.Services.AddScoped(typeof(IRepository<>), typeof(GenericRepository<>));
builder.Services.AddScoped(typeof(IService<,>), typeof(GenericService<,>));


builder.Services.AddAuthentication("Bearer")
    .AddJwtBearer("Bearer", options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!)
            )
        };
    });

builder.Services.AddAuthorization();



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

//загрузка картинок
app.UseStaticFiles();

// регистрация маппинга
MappingConfig.RegisterMappings();

// HTTPS редирект (http → https)
app.UseHttpsRedirection();

// Middleware авторизации (пока что бесполезно, если нет аутентификации)
app.UseAuthorization();

// Маршрутизация контроллеров
app.MapControllers();

app.UseAuthentication(); // обязательно до UseAuthorization
app.UseAuthorization();

// Регистрируем маппинги (например, AutoMapper)
Optika.API.Mapping.MappingConfig.RegisterMappings();

app.Run();

