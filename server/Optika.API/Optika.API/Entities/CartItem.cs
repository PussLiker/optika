namespace Optika.API.Entities
{
    public class CartItem
    {
        public int Id { get; set; }

        public int CartId { get; set; }
        public Cart Cart { get; set; } = null!;

        public int ProductId { get; set; }
        public Products Product { get; set; } = null!;

        public int Quantity { get; set; }

    }
}
