using TranslationBureau.Application.Common;
using TranslationBureau.Application.DTOs;

namespace TranslationBureau.Web.ViewModels;

/// <summary>Модель представления перечня переводчиков.</summary>
public class TranslatorIndexViewModel
{
    public PagedResult<TranslatorDto> Translators { get; set; } = new();
    public TranslatorFilterDto Filter { get; set; } = new();
    public IReadOnlyList<string> Categories { get; set; } = [];
}
