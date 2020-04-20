

class InvalidLanguageException implements Exception {}

enum Language {
    french,
    german,
    spanish,
}

extension LanguageCodes on Language {
    String get code {
        switch(this) {
            case Language.french:
                return 'fr';
            case Language.german:
                return 'de';
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
            case Language.french:
                return 'French';
            case Language.german:
                return 'German';
            case Language.spanish:
                return 'Spanish';
        }
        throw InvalidLanguageException();
    }
}