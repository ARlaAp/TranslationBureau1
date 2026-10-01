using TranslationBureau.Domain.Common;
using TranslationBureau.Domain.Exceptions;

namespace TranslationBureau.Domain.Entities;

/// <summary>Переводчик бюро переводов.</summary>
public class Translator : Entity
{
    /// <summary>Конструктор без параметров требуется Entity Framework Core.</summary>
    private Translator()
    {
    }

    private Translator(string fullName, string? phone, string? email,
        string? category, decimal ratePerUnit)
    {
        FullName = fullName;
        Phone = phone;
        Email = email;
        Category = category;
        RatePerUnit = ratePerUnit;
        IsActive = true;
    }

    public string FullName { get; private set; } = string.Empty;
    public string? Phone { get; private set; }
    public string? Email { get; private set; }
    public string? Category { get; private set; }
    public decimal RatePerUnit { get; private set; }
    public bool IsActive { get; private set; }

    /// <summary>Фабричный метод создания переводчика с проверкой правил
    /// предметной области.</summary>
    public static Translator Create(string fullName, string? phone, string? email,
        string? category, decimal ratePerUnit)
    {
        Validate(fullName, ratePerUnit);

        return new Translator(fullName.Trim(), phone, email, category, ratePerUnit);
    }

    /// <summary>Изменяет реквизиты переводчика.</summary>
    public void Update(string fullName, string? phone, string? email,
        string? category, decimal ratePerUnit)
    {
        Validate(fullName, ratePerUnit);

        FullName = fullName.Trim();
        Phone = phone;
        Email = email;
        Category = category;
        RatePerUnit = ratePerUnit;
    }

    /// <summary>Переводит запись в архивное состояние вместо физического удаления.</summary>
    public void Deactivate() => IsActive = false;

    public void Activate() => IsActive = true;

    private static void Validate(string fullName, decimal ratePerUnit)
    {
        if (string.IsNullOrWhiteSpace(fullName))
        {
            throw new DomainException("ФИО переводчика не может быть пустым.");
        }

        if (ratePerUnit <= 0)
        {
            throw new DomainException("Ставка переводчика должна быть положительной.");
        }
    }
}
