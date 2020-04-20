

import 'package:camera/camera.dart';
import 'package:smart_labels2/model/Constants.dart';
import 'Language.dart';
import 'package:hive/hive.dart';

class AppStateObserver {
    void willSetSelectedLanguage(Language newLanguage) {}
    void didSetSelectedLanguage(Language oldLanguage){}
}

class AlreadyInstantiatedException implements Exception {}

class AppState {
    String _detectionModel;
    String get detectionModel => _detectionModel;

    List<CameraDescription> _cameras;
    List<CameraDescription> get cameras => _cameras;

    Language _selectedLanguage;
    Language get selectedLanguage => _selectedLanguage;
    set selectedLanguage(Language newLanguage) {
        _observers.forEach( (obs) {
            obs.willSetSelectedLanguage(newLanguage);
        });
        Language oldLanguage = _selectedLanguage;
        _selectedLanguage = newLanguage;
        _observers.forEach( (obs) {
            obs.didSetSelectedLanguage(oldLanguage);
        });
    }

    List<AppStateObserver> _observers = [];
    void subscribe(AppStateObserver obs) {
        _observers.add(obs);
    }
    void unsubscribe(AppStateObserver obs) {
        _observers.remove(obs);
    }

    void init(_detectionModel, _cameras) {
        this._detectionModel = _detectionModel;
        this._cameras = _cameras;
        var configBox = Hive.box(HiveKeys.configBox);
        _selectedLanguage = LanguageCodes.languageFromCode(configBox.get(HiveKeys.selectedLanguageKey));
    }

    static final AppState _instance = AppState._internal();

    AppState._internal();

    factory AppState() {
        return _instance;
    }
}
