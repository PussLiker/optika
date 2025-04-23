namespace Optika.API.DTOs
{
    public class BrandDto
    {
        public int Id { get; set; }

        public string Name { get; set; } = null!;

        public string? Country { get; set; }
    }
}
