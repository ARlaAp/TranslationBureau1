namespace TranslationBureau.Application.DTOs;

/// <summary>Объект передачи сведений о переводчике в слой представления.</summary>
public class TranslatorDto
{
    public int Id { get; init; }
    public string FullName { get; init; } = string.Empty;
    public string? Phone { get; init; }
    public string? Email { get; init; }
    public string? Category { get; init; }
    public decimal RatePerUnit { get; init; }
    public bool IsActive { get; init; }
}
