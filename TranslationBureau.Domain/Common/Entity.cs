namespace TranslationBureau.Domain.Common;

/// <summary>Базовый класс доменной сущности, обладающей идентификатором.</summary>
public abstract class Entity
{
    public int Id { get; protected set; }

    public override bool Equals(object? obj)
    {
        if (obj is not Entity other || GetType() != other.GetType())
        {
            return false;
        }

        // Сущности, не сохранённые в хранилище, сравниваются по ссылке
        if (Id == 0 || other.Id == 0)
        {
            return ReferenceEquals(this, other);
        }

        return Id == other.Id;
    }

    public override int GetHashCode() => HashCode.Combine(GetType(), Id);
}
    