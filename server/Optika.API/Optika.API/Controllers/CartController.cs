using System.IdentityModel.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Optika.API.Data;
using Optika.API.DTOs;
using Optika.API.Entities;

[Authorize]
[ApiController]
[Route("api/[controller]")]
public class CartController : ControllerBase
{
    private readonly AppDbContext _context;

    public CartController(AppDbContext context)
    {
        _context = context;
    }

    [HttpPut("update")]
    public async Task<IActionResult> UpdateCartItem(AddToCartDto dto)
    {
        int userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var cart = await _context.Carts
            .Include(c => c.Items)
            .FirstOrDefaultAsync(c => c.UserId == userId);

        if (cart == null)
            return NotFound("Корзина не найдена");

        var item = cart.Items.FirstOrDefault(i => i.ProductId == dto.ProductId);
        if (item == null)
            return NotFound("Товар не найден в корзине");

        item.Quantity = dto.Quantity;
        await _context.SaveChangesAsync();

        return Ok();
    }

    [HttpPost("add")]
    public async Task<IActionResult> AddToCart(AddToCartDto dto)
    {
        int userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var cart = await _context.Carts
            .Include(c => c.Items)
            .FirstOrDefaultAsync(c => c.UserId == userId);

        if (cart == null)
        {
            cart = new Cart { UserId = userId };
            _context.Carts.Add(cart);
            await _context.SaveChangesAsync(); // получить CartId
        }

        var existingItem = cart.Items.FirstOrDefault(i => i.ProductId == dto.ProductId);

        if (existingItem != null)
        {
            existingItem.Quantity += dto.Quantity;
        }
        else
        {
            cart.Items.Add(new CartItem
            {
                ProductId = dto.ProductId,
                Quantity = dto.Quantity,
                CartId = cart.Id
            });
        }

        await _context.SaveChangesAsync();
        return Ok("Товар добавлен в корзину");
    }


    [HttpGet]
    public async Task<IActionResult> GetCart()
    {
        int userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var cart = await _context.Carts
            .Include(c => c.Items)
            .ThenInclude(i => i.Product)
            .FirstOrDefaultAsync(c => c.UserId == userId);

        if (cart == null || !cart.Items.Any())
            return NotFound("Корзина пуста");

        var result = cart.Items.Select(i => new CartItemDto
        {
            ProductId = i.ProductId,
            Name = i.Product.Name,
            Price = i.Product.Price,
            Quantity = i.Quantity,
            ImageUrl = i.Product.ImageUrl,
            BrandName = i.Product.Brand.Name
        });

        return Ok(result);
    }

    [HttpDelete("{productId}")]
    public async Task<IActionResult> RemoveFromCart(int productId)
    {
        int userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var cart = await _context.Carts
            .Include(c => c.Items)
            .FirstOrDefaultAsync(c => c.UserId == userId);

        if (cart == null) return NotFound();

        var item = cart.Items.FirstOrDefault(i => i.ProductId == productId);
        if (item == null) return NotFound();

        _context.CartItems.Remove(item);
        await _context.SaveChangesAsync();

        return Ok("Товар удалён из корзины");
    }

    [HttpDelete]
    public async Task<IActionResult> ClearCart()
    {
        int userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var cart = await _context.Carts
            .Include(c => c.Items)
            .FirstOrDefaultAsync(c => c.UserId == userId);

        if (cart == null || !cart.Items.Any())
            return NotFound("Корзина пуста");

        _context.CartItems.RemoveRange(cart.Items);
        await _context.SaveChangesAsync();

        return Ok("Корзина очищена");
    }
}
