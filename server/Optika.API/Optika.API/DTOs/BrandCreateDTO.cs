using System.ComponentModel.DataAnnotations;

namespace Optika.API.DTOs
{
    public class BrandCreateDto
    {
        [Required, MaxLength(100)]
        public string Name { get; set; } = null!;

        public string? Country { get; set; }
    }
}
