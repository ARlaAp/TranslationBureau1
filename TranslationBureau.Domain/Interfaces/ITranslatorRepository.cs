using TranslationBureau.Domain.Entities;

namespace TranslationBureau.Domain.Interfaces;

public interface ITranslatorRepository
{
    /// <summary>Возвращает запрос, допускающий последующее уточнение.</summary>
    IQueryable<Translator> Query();

    Task<Translator?> GetByIdAsync(int id, CancellationToken cancellationToken = default);

    Task AddAsync(Translator translator, CancellationToken cancellationToken = default);

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
