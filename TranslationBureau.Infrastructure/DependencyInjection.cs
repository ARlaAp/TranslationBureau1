using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using TranslationBureau.Domain.Interfaces;
using TranslationBureau.Infrastructure.Persistence;
using TranslationBureau.Infrastructure.Persistence.Repositories;

namespace TranslationBureau.Infrastructure;

public static class DependencyInjection
{
    /// <summary>Регистрирует контекст базы данных и реализации репозиториев.</summary>
    public static IServiceCollection AddInfrastructure(this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException(
                "Строка подключения «DefaultConnection» не найдена.");

        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(connectionString));

        services.AddScoped<ITranslatorRepository, TranslatorRepository>();

        return services;
    }
}
