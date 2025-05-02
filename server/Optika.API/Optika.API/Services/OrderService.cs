using Microsoft.EntityFrameworkCore;
using Optika.API.Data;
using Optika.API.DTOs;
using Optika.API.Entities;

namespace Optika.API.Services
{
    public class OrderService : IOrderService
    {
        private readonly AppDbContext _context;

        public OrderService(AppDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Order>> GetAllAsync()
        {
            return await _context.Orders
                .Include(o => o.Items)
                .ToListAsync();
        }

        public async Task<Order?> GetByIdAsync(int id)
        {
            return await _context.Orders
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.Id == id);
        }

        public async Task<Order> CreateAsync(int userId, OrderCreateDto dto)
        {
            var order = new Order
            {
                UserId = userId,
                TotalPrice = dto.TotalPrice,
                Status = dto.Status,
                CreatedAt = DateTime.UtcNow,
                Items = dto.Items.Select(i => new OrderItem
                {
                    ProductId = i.ProductId,
                    Quantity = i.Quantity,
                    Price = i.Price
                }).ToList()
            };

            _context.Orders.Add(order);
            await _context.SaveChangesAsync();

            return order;
        }

        public async Task<Order?> UpdateAsync(int id, OrderCreateDto dto)
        {
            var existing = await _context.Orders
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.Id == id);

            if (existing == null)
                return null;

            // Удаляем старые OrderItems
            _context.OrderItems.RemoveRange(existing.Items);

            existing.TotalPrice = dto.TotalPrice;
            existing.Status = dto.Status;
            existing.Items = dto.Items.Select(i => new OrderItem
            {
                ProductId = i.ProductId,
                Quantity = i.Quantity,
                Price = i.Price
            }).ToList();

            await _context.SaveChangesAsync();

            return existing;
        }

        public async Task DeleteAsync(int id)
        {
            var order = await _context.Orders
                .Include(o => o.Items)
                .FirstOrDefaultAsync(o => o.Id == id);

            if (order == null)
                throw new ArgumentException("Order not found");

            _context.OrderItems.RemoveRange(order.Items);
            _context.Orders.Remove(order);

            await _context.SaveChangesAsync();
        }
    }
}
