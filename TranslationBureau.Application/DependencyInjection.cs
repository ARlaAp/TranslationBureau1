using Microsoft.Extensions.DependencyInjection;
using TranslationBureau.Application.Interfaces;
using TranslationBureau.Application.Services;

namespace TranslationBureau.Application;

public static class DependencyInjection
{
    /// <summary>Регистрирует службы слоя приложения.</summary>
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<ITranslatorService, TranslatorService>();
        return services;
    }
}
