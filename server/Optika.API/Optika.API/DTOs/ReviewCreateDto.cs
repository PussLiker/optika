using System.ComponentModel.DataAnnotations;

namespace Optika.API.DTOs
{
    public class ReviewCreateDto
    {
        [Required]
        public int ProductId { get; set; }

        [Required]
        public int Rating { get; set; } // 1-5

        public string? Comment { get; set; }
    }
}