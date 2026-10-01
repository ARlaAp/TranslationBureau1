using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using TranslationBureau.Domain.Entities;

namespace TranslationBureau.Infrastructure.Persistence.Configurations;

/// <summary>Конфигурация отображения сущности «Переводчик» на таблицу.</summary>
public class TranslatorConfiguration : IEntityTypeConfiguration<Translator>
{
    public void Configure(EntityTypeBuilder<Translator> builder)
    {
        builder.ToTable("Translators");
        builder.HasKey(t => t.Id);

        builder.Property(t => t.FullName)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(t => t.Phone).HasMaxLength(20);
        builder.Property(t => t.Email).HasMaxLength(100);
        builder.Property(t => t.Category).HasMaxLength(50);

        // Явное указание типа столбца исключает предупреждение
        // о возможной потере точности при отображении типа decimal
        builder.Property(t => t.RatePerUnit).HasColumnType("decimal(10,2)");

        builder.HasIndex(t => t.FullName);
    }
}
