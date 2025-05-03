using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Optika.API.Data;
using Optika.API.DTOs;
using Optika.API.Entities;
using System.Security.Claims;


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

    [HttpPost("add")]
    public async Task<IActionResult> AddToCart([FromBody] AddToCartDto dto)
    {
        int userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var cart = await _context.Carts
            .Include(c => c.Items)
            .FirstOrDefaultAsync(c => c.UserId == userId);

        if (cart == null)
        {
            cart = new Cart { UserId = userId };
            _context.Carts.Add(cart);
        }


        var item = cart.Items.FirstOrDefault(i => i.ProductId == dto.ProductId);
        if (item != null)
        {
            item.Quantity += dto.Quantity;
        }
        else
        {
            cart.Items.Add(new CartItem
            {
                ProductId = dto.ProductId,
                Quantity = dto.Quantity
            });
        }

        await _context.SaveChangesAsync();
        return Ok("Добавлено в корзину");
    }

    [HttpGet]
    public async Task<IActionResult> GetCart()
    {
        int userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        var cart = await _context.Carts
            .Include(c => c.Items)
            .ThenInclude(i => i.Product)
            .FirstOrDefaultAsync(c => c.UserId == userId);

        if (cart == null)
            return NotFound("Корзина не найдена");

        var result = cart.Items.Select(i => new
        {
            i.ProductId,
            i.Product.Name,
            i.Product.Price,
            i.Quantity
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

        if (item.Quantity <= 0)
        {
            cart.Items.Remove(item);
        }

        _context.CartItems.Remove(item);
        await _context.SaveChangesAsync();

        return Ok("Удалено");
    }
}
