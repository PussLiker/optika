namespace Optika.API.DTOs
{
    public class OrderDto
    {
        public int Id { get; set; }

        public int UserId { get; set; }

        public DateTime CreatedAt { get; set; }

        public decimal TotalPrice { get; set; }

        public string Status { get; set; } = "Pending";

        public ICollection<OrderItemDto> Items { get; set; } = new List<OrderItemDto>();
    }
}
