using Microsoft.EntityFrameworkCore;
using TranslationBureau.Application.Common;
using TranslationBureau.Application.DTOs;
using TranslationBureau.Application.Interfaces;
using TranslationBureau.Application.Mapping;
using TranslationBureau.Domain.Entities;
using TranslationBureau.Domain.Exceptions;
using TranslationBureau.Domain.Interfaces;

namespace TranslationBureau.Application.Services;

public class TranslatorService : ITranslatorService
{
    private readonly ITranslatorRepository _repository;

    public TranslatorService(ITranslatorRepository repository)
        => _repository = repository;

    public async Task<PagedResult<TranslatorDto>> GetPagedAsync(
        TranslatorFilterDto filter, CancellationToken cancellationToken = default)
    {
        var query = _repository.Query();

        // Отбор записей по заданным условиям
        if (!string.IsNullOrWhiteSpace(filter.Category))
        {
            query = query.Where(t => t.Category == filter.Category);
        }

        if (filter.IsActive.HasValue)
        {
            query = query.Where(t => t.IsActive == filter.IsActive.Value);
        }

        // Упорядочение записей
        query = filter.SortOrder switch
        {
            "name_desc" => query.OrderByDescending(t => t.FullName),
            "rate" => query.OrderBy(t => t.RatePerUnit),
            "rate_desc" => query.OrderByDescending(t => t.RatePerUnit),
            _ => query.OrderBy(t => t.FullName)
        };

        var totalCount = await query.CountAsync(cancellationToken);

        var items = await query
            .Skip((filter.Page - 1) * filter.PageSize)
            .Take(filter.PageSize)
            .ToListAsync(cancellationToken);

        return new PagedResult<TranslatorDto>
        {
            Items = items.Select(t => t.ToDto()).ToList(),
            PageIndex = filter.Page,
            PageSize = filter.PageSize,
            TotalCount = totalCount
        };
    }

    public async Task<IReadOnlyList<string>> GetCategoriesAsync(
        CancellationToken cancellationToken = default)
        => await _repository.Query()
            .Where(t => t.Category != null)
            .Select(t => t.Category!)
            .Distinct()
            .OrderBy(c => c)
            .ToListAsync(cancellationToken);

    public async Task<TranslatorDto?> GetByIdAsync(int id,
        CancellationToken cancellationToken = default)
    {
        var translator = await _repository.GetByIdAsync(id, cancellationToken);
        return translator?.ToDto();
    }

    public async Task<TranslatorInputDto?> GetForEditAsync(int id,
        CancellationToken cancellationToken = default)
    {
        var translator = await _repository.GetByIdAsync(id, cancellationToken);
        return translator?.ToInputDto();
    }

    public async Task<int> CreateAsync(TranslatorInputDto dto,
        CancellationToken cancellationToken = default)
    {
        // Правила предметной области проверяются доменной сущностью
        var translator = Translator.Create(dto.FullName, dto.Phone,
            dto.Email, dto.Category, dto.RatePerUnit);

        await _repository.AddAsync(translator, cancellationToken);
        await _repository.SaveChangesAsync(cancellationToken);

        return translator.Id;
    }

    public async Task UpdateAsync(TranslatorInputDto dto,
        CancellationToken cancellationToken = default)
    {
        var translator = await _repository.GetByIdAsync(dto.Id, cancellationToken)
            ?? throw new DomainException("Переводчик не найден.");

        translator.Update(dto.FullName, dto.Phone, dto.Email,
            dto.Category, dto.RatePerUnit);

        await _repository.SaveChangesAsync(cancellationToken);
    }

    public async Task DeactivateAsync(int id, CancellationToken cancellationToken = default)
    {
        var translator = await _repository.GetByIdAsync(id, cancellationToken)
            ?? throw new DomainException("Переводчик не найден.");

        // Вместо физического удаления запись переводится в архивное состояние,
        // поскольку на неё могут ссылаться ранее выполненные заказы
        translator.Deactivate();

        await _repository.SaveChangesAsync(cancellationToken);
    }
}
