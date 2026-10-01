using TranslationBureau.Application.DTOs;
using TranslationBureau.Domain.Entities;

namespace TranslationBureau.Application.Mapping;

/// <summary>Методы преобразования доменных сущностей в объекты передачи данных.</summary>
public static class MappingExtensions
{
    public static TranslatorDto ToDto(this Translator translator) => new()
    {
        Id = translator.Id,
        FullName = translator.FullName,
        Phone = translator.Phone,
        Email = translator.Email,
        Category = translator.Category,
        RatePerUnit = translator.RatePerUnit,
        IsActive = translator.IsActive
    };

    public static TranslatorInputDto ToInputDto(this Translator translator) => new()
    {
        Id = translator.Id,
        FullName = translator.FullName,
        Phone = translator.Phone,
        Email = translator.Email,
        Category = translator.Category,
        RatePerUnit = translator.RatePerUnit
    };
}
