

import 'package:camera/camera.dart';
import 'package:smart_labels2/model/Constants.dart';
import 'package:smart_labels2/services/TfliteClient.dart';
import 'Language.dart';
import 'package:hive/hive.dart';

class AppStateObserver {
    void willSetSelectedLanguage(Language newLanguage) {}
    void didSetSelectedLanguage(Language oldLanguage){}
}

class AlreadyInstantiatedException implements Exception {}

class AppState {
    TfliteClient _tfliteClient;
    TfliteClient get tfliteClient => _tfliteClient;

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

    void init(_tfliteClient, _cameras) {
        this._tfliteClient = _tfliteClient;
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
