using TranslationBureau.Application.Common;
using TranslationBureau.Application.DTOs;

namespace TranslationBureau.Application.Interfaces;

public interface ITranslatorService
{
    Task<PagedResult<TranslatorDto>> GetPagedAsync(TranslatorFilterDto filter,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<string>> GetCategoriesAsync(
        CancellationToken cancellationToken = default);

    Task<TranslatorDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default);

    Task<TranslatorInputDto?> GetForEditAsync(int id,
        CancellationToken cancellationToken = default);

    Task<int> CreateAsync(TranslatorInputDto dto,
        CancellationToken cancellationToken = default);

    Task UpdateAsync(TranslatorInputDto dto, CancellationToken cancellationToken = default);

    Task DeactivateAsync(int id, CancellationToken cancellationToken = default);
}
