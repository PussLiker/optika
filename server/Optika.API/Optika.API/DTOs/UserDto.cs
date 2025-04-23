// UserDto.cs
namespace Optika.API.DTOs
{
    public class UserDto
    {
        public int Id { get; set; }

        public string Name { get; set; } = null!;

        public string LastName { get; set; } = null!;

        public string Email { get; set; } = null!;

        public string Role { get; set; } = "User";

        public DateTime CreatedAt { get; set; }

        public bool IsActive { get; set; }
    }
}
