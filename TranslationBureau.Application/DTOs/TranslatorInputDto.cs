using System.ComponentModel.DataAnnotations;

namespace TranslationBureau.Application.DTOs;

/// <summary>Объект передачи данных, вводимых пользователем.</summary>
public class TranslatorInputDto
{
    public int Id { get; set; }

    [Display(Name = "ФИО")]
    [Required(ErrorMessage = "Укажите ФИО переводчика")]
    [StringLength(150, ErrorMessage = "Длина ФИО не должна превышать 150 символов")]
    public string FullName { get; set; } = string.Empty;

    [Display(Name = "Телефон")]
    [Phone(ErrorMessage = "Некорректный номер телефона")]
    [StringLength(20)]
    public string? Phone { get; set; }

    [Display(Name = "Электронная почта")]
    [EmailAddress(ErrorMessage = "Некорректный адрес электронной почты")]
    [StringLength(100)]
    public string? Email { get; set; }

    [Display(Name = "Категория")]
    [StringLength(50)]
    public string? Category { get; set; }

    [Display(Name = "Ставка за единицу, руб.")]
    [Range(0.01, 100000, ErrorMessage = "Ставка должна быть положительной")]
    public decimal RatePerUnit { get; set; }
}
