using Microsoft.EntityFrameworkCore;
using TranslationBureau.Domain.Entities;

namespace TranslationBureau.Infrastructure.Persistence;

/// <summary>Контекст базы данных бюро переводов.</summary>
public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Translator> Translators => Set<Translator>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Применение всех классов конфигурации, объявленных в данной сборке
        modelBuilder.ApplyConfigurationsFromAssembly(
            typeof(ApplicationDbContext).Assembly);

        base.OnModelCreating(modelBuilder);
    }
}
