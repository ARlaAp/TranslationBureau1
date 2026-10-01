using Microsoft.EntityFrameworkCore;
using TranslationBureau.Domain.Entities;
using TranslationBureau.Domain.Interfaces;

namespace TranslationBureau.Infrastructure.Persistence.Repositories;

public class TranslatorRepository : ITranslatorRepository
{
    private readonly ApplicationDbContext _context;

    public TranslatorRepository(ApplicationDbContext context)
        => _context = context;

    public IQueryable<Translator> Query()
        => _context.Translators.AsNoTracking();

    public async Task<Translator?> GetByIdAsync(int id,
        CancellationToken cancellationToken = default)
        => await _context.Translators
            .FirstOrDefaultAsync(t => t.Id == id, cancellationToken);

    public async Task AddAsync(Translator translator,
        CancellationToken cancellationToken = default)
        => await _context.Translators.AddAsync(translator, cancellationToken);

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        => _context.SaveChangesAsync(cancellationToken);
}
