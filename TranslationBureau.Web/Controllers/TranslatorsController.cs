using Microsoft.AspNetCore.Mvc;
using TranslationBureau.Application.DTOs;
using TranslationBureau.Application.Interfaces;
using TranslationBureau.Domain.Exceptions;
using TranslationBureau.Web.ViewModels;

namespace TranslationBureau.Web.Controllers;

public class TranslatorsController : Controller
{
    private readonly ITranslatorService _service;

    public TranslatorsController(ITranslatorService service)
        => _service = service;

    public async Task<IActionResult> Index([FromQuery] TranslatorFilterDto filter,
        CancellationToken cancellationToken)
    {
        var model = new TranslatorIndexViewModel
        {
            Translators = await _service.GetPagedAsync(filter, cancellationToken),
            Filter = filter,
            Categories = await _service.GetCategoriesAsync(cancellationToken)
        };

        return View(model);
    }

    public IActionResult Create() => View(new TranslatorInputDto());

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Create(TranslatorInputDto model,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return View(model);
        }

        try
        {
            await _service.CreateAsync(model, cancellationToken);
            return RedirectToAction(nameof(Index));
        }
        catch (DomainException exception)
        {
            ModelState.AddModelError(string.Empty, exception.Message);
            return View(model);
        }
    }

    public async Task<IActionResult> Edit(int id, CancellationToken cancellationToken)
    {
        var model = await _service.GetForEditAsync(id, cancellationToken);
        return model is null ? NotFound() : View(model);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Edit(TranslatorInputDto model,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid)
        {
            return View(model);
        }

        try
        {
            await _service.UpdateAsync(model, cancellationToken);
            return RedirectToAction(nameof(Index));
        }
        catch (DomainException exception)
        {
            ModelState.AddModelError(string.Empty, exception.Message);
            return View(model);
        }
    }

    public async Task<IActionResult> Delete(int id, CancellationToken cancellationToken)
    {
        var model = await _service.GetByIdAsync(id, cancellationToken);
        return model is null ? NotFound() : View(model);
    }

    [HttpPost]
    [ActionName("Delete")]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> DeleteConfirmed(int id,
        CancellationToken cancellationToken)
    {
        await _service.DeactivateAsync(id, cancellationToken);
        return RedirectToAction(nameof(Index));
    }
}
