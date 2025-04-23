using System.ComponentModel.DataAnnotations;

namespace Optika.API.DTOs
{
    public class CategoryCreateDto
    {
        [Required, MaxLength(100)]
        public string Name { get; set; } = null!;

        public string? Description { get; set; }
    }
}
