\# Бюро переводов



!\[Build Status](https://github.com/ИМЯ\_УЧЁТНОЙ\_ЗАПИСИ/TranslationBureau/actions/workflows/build.yml/badge.svg)



Web-приложение баз данных «Бюро переводов», разработанное в ходе изучения

дисциплины «Разработка приложений баз данных для информационных систем».



\## Состав решения



| Проект | Назначение |

| --- | --- |

| `TranslationBureau.Domain` | доменное ядро |

| `TranslationBureau.Application` | сценарии использования |

| `TranslationBureau.Infrastructure` | инфраструктура и доступ к данным |

| `TranslationBureau.Web` | Web-приложение ASP.NET Core MVC |

| `TranslationBureau.Tests` | модульные тесты |



\## Требования



Для сборки и запуска требуются пакет .NET 10.0 SDK и система управления

базами данных MS SQL Server (допускается использование LocalDB).



\## Запуск



&#x20;   dotnet run --project TranslationBureau.Web



\## Выполнение модульных тестов



&#x20;   dotnet test





