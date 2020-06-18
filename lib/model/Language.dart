

class InvalidLanguageException implements Exception {}

enum Language {
    czech,
    danish,
    dutch,
    french,
    german,
    greek,
    hungarian,
    italian,
    polish,
    portuguese,
    romanian,
    russian,
    spanish,
}

extension LanguageCodes on Language {
    String get code {
        switch(this) {
            case Language.czech:
                return 'cs';
            case Language.danish:
                return 'da';
            case Language.dutch:
                return 'nl';
            case Language.french:
                return 'fr';
            case Language.german:
                return 'de';
            case Language.greek:
                return 'el';
            case Language.hungarian:
                return 'hu';
            case Language.italian:
                return 'it';
            case Language.polish:
                return 'pl';
            case Language.portuguese:
                return 'pt';
            case Language.romanian:
                return 'ro';
            case Language.russian:
                return 'ru';
            case Language.spanish:
                return 'es';
        }
        throw InvalidLanguageException();
    }

    static Language languageFromCode(String code) {
        var langs = Language.values.where((language) => language.code == code).toList();
        if(langs.length > 0) {
            return langs[0];
        }
        return null;
    }
}

extension LanguageDescription on Language {
    String get description {
        switch(this) {
            case Language.czech:
                return 'Czech';
            case Language.danish:
                return 'Danish';
            case Language.dutch:
                return 'Dutch';
            case Language.french:
                return 'French';
            case Language.german:
                return 'German';
            case Language.greek:
                return 'Greek';
            case Language.hungarian:
                return 'Hungarian';
            case Language.italian:
                return 'Italian';
            case Language.polish:
                return 'Polish';
            case Language.portuguese:
                return 'Portuguese';
            case Language.romanian:
                return 'Romanian';
            case Language.russian:
                return 'Russian';
            case Language.spanish:
                return 'Spanish';
        }
        throw InvalidLanguageException();
    }
}