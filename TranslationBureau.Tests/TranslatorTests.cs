using TranslationBureau.Domain.Entities;
using TranslationBureau.Domain.Exceptions;
using Xunit;

namespace TranslationBureau.Tests;

public class TranslatorTests
{
    [Fact]
    public void Create_ПриКорректныхДанных_СоздаётАктивногоПереводчика()
    {
        var translator = Translator.Create("Иванова Мария Петровна",
            "+375291234567", "ivanova@example.com", "высшая", 22m);

        Assert.Equal("Иванова Мария Петровна", translator.FullName);
        Assert.Equal(22m, translator.RatePerUnit);
        Assert.True(translator.IsActive);
    }

    [Fact]
    public void Create_ПриПустомЗначенииФИО_ВозбуждаетИсключение()
    {
        Assert.Throws<DomainException>(() =>
            Translator.Create("   ", null, null, "первая", 18m));
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public void Create_ПриНеположительнойСтавке_ВозбуждаетИсключение(decimal rate)
    {
        Assert.Throws<DomainException>(() =>
            Translator.Create("Петров Сергей Николаевич", null, null, "первая", rate));
    }

    [Fact]
    public void Deactivate_ПереводитЗаписьВАрхивноеСостояние()
    {
        var translator = Translator.Create("Сидорова Анна Игоревна",
            null, null, "вторая", 15m);

        translator.Deactivate();

        Assert.False(translator.IsActive);
    }
}
