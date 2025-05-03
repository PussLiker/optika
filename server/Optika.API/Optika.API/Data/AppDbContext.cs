using Microsoft.EntityFrameworkCore;
using Optika.API.Entities;

namespace Optika.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        // Таблицы
        public DbSet<Products> Products => Set<Products>();
        public DbSet<Category> Categories => Set<Category>();
        public DbSet<Brand> Brands => Set<Brand>();
        public DbSet<Order> Orders => Set<Order>();
        public DbSet<OrderItem> OrderItems => Set<OrderItem>();
        public DbSet<User> Users => Set<User>();
        public DbSet<Cart> Carts { get; set; } = null!;
        public DbSet<CartItem> CartItems { get; set; } = null!;


        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Конфигурация Product
            modelBuilder.Entity<Products>(entity =>
            {
                entity.HasKey(p => p.Id);
                entity.Property(p => p.Name).IsRequired().HasMaxLength(100);
                entity.Property(p => p.Description).HasMaxLength(1000);
                entity.Property(p => p.Price).HasPrecision(10, 2); // PostgreSQL-friendly
                entity.Property(p => p.ImageUrl).HasMaxLength(2048);
                entity.Property(p => p.CreatedAt).HasDefaultValueSql("NOW()");
            });

            // Конфигурация Category
            modelBuilder.Entity<Category>(entity =>
            {
                entity.HasKey(c => c.Id);
                entity.Property(c => c.Name).IsRequired().HasMaxLength(100);
                entity.Property(c => c.Description).HasMaxLength(500);
            });

            // Конфигурация Brand
            modelBuilder.Entity<Brand>(entity =>
            {
                entity.HasKey(b => b.Id);
                entity.Property(b => b.Name).IsRequired().HasMaxLength(100);
            });

            // Конфигурация User
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(u => u.Id);
                entity.Property(u => u.Email).IsRequired().HasMaxLength(256);
                entity.Property(u => u.PasswordHash).IsRequired().HasMaxLength(512);
                entity.Property(u => u.Name).HasMaxLength(200);
                entity.Property(u => u.LastName).HasMaxLength(200);
                entity.Property(u => u.Role).HasMaxLength(50).HasDefaultValue("Customer");
                entity.Property(u => u.CreatedAt).HasDefaultValueSql("NOW()");
            });

            // Конфигурация Cart (1:1 с User)
            modelBuilder.Entity<Cart>()
                .HasOne(c => c.User)
                .WithOne(u => u.Cart)
                .HasForeignKey<Cart>(c => c.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            // Конфигурация CartItem
            modelBuilder.Entity<CartItem>(entity =>
            {
                entity.HasKey(i => i.Id);

                entity.HasOne(i => i.Cart)
                    .WithMany(c => c.Items)
                    .HasForeignKey(i => i.CartId)
                    .OnDelete(DeleteBehavior.Cascade);

                entity.HasOne(i => i.Product)
                    .WithMany()
                    .HasForeignKey(i => i.ProductId)
                    .OnDelete(DeleteBehavior.Restrict); // запрет каскадного удаления продуктов

                entity.HasIndex(i => new { i.CartId, i.ProductId }).IsUnique(); // уникальная пара
            });

            // Конфигурация Order
            modelBuilder.Entity<Order>(entity =>
            {
                entity.HasKey(o => o.Id);
                entity.Property(o => o.UserId).IsRequired();
                entity.Property(o => o.CreatedAt).HasDefaultValueSql("NOW()");
                entity.Property(o => o.Status).HasMaxLength(50);
            });

            // Конфигурация OrderItem
            modelBuilder.Entity<OrderItem>(entity =>
            {
                entity.HasKey(oi => oi.Id);
                entity.Property(oi => oi.OrderId).IsRequired();
                entity.Property(oi => oi.ProductId).IsRequired();
                entity.Property(oi => oi.Quantity).IsRequired();
                entity.Property(oi => oi.Price).HasPrecision(10, 2); // PostgreSQL-friendly
            });
        }

    }
}
