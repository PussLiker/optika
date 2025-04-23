using System.ComponentModel.DataAnnotations;

namespace Optika.API.Entities
{
    public class Brand
    {
        public int Id { get; set; }

        [Required, MaxLength(100)]
        public string Name { get; set; } = null!;

        [MaxLength(100)]
        public string? Country { get; set; }

        public ICollection<Product> Products { get; set; } = new List<Product>();

    }
}
