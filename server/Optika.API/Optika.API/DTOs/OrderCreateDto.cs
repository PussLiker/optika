using System.ComponentModel.DataAnnotations;

namespace Optika.API.DTOs
{
    public class OrderCreateDto
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public ICollection<OrderItemCreateDto> Items { get; set; } = new List<OrderItemCreateDto>();

        [Required]
        [Range(0.01, double.MaxValue, ErrorMessage = "TotalPrice must be greater than 0.")]
        public decimal TotalPrice { get; set; }

        [Required]
        [MaxLength(50)]
        public string Status { get; set; } = "Pending";
    }
}
