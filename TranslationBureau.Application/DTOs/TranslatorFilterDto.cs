namespace TranslationBureau.Application.DTOs;

/// <summary>Условия отбора и упорядочения перечня переводчиков.</summary>
public class TranslatorFilterDto
{
    public string? Category { get; set; }
    public bool? IsActive { get; set; }
    public string? SortOrder { get; set; }
    public int Page { get; set; } = 1;
    public int PageSize { get; set; } = 5;
}
