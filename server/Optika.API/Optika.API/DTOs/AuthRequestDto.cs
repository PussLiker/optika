using System.ComponentModel.DataAnnotations;

namespace Optika.API.DTOs
{
    public class AuthRequestDto
    {
        [Required, EmailAddress]
        public string Email { get; set; } = null!;

        [Required]
        public string Password { get; set; } = null!;
    }
}
