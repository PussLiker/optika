namespace Optika.API.DTOs
{
    public class ReviewDto
    {
        public int Id { get; set; }

        public int UserId { get; set; }

        public string UserName { get; set; } = null!;

        public int ProductId { get; set; }

        public string ProductName { get; set; } = null!;

        public int Rating { get; set; }

        public string? Comment { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
