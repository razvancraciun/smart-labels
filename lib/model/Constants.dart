

class HiveKeys {
    static final String configBox = 'config';
    static final String selectedLanguageKey = 'selectedLanguage';
}

class ApiConstants {
    static final String remoteConfigTranslateKey = 'watson_translate_key';
    static final String translateClientUser = 'apikey';
    static final String translateClientURL = 'https://api.eu-gb.language-translator.watson.cloud.ibm.com/instances/2c3253c0-4abd-4273-9497-e927cea6aba0/v3/translate?version=2018-05-01';
}

class AssetPath {
    static final String yoloModelPath = 'assets/tflite/yolov2_tiny.tflite';
    static final String yoloLabelsPath = 'assets/tflite/yolov2_tiny.txt';
    static final String ownModelPath = 'assets/tflite/save0419-1241.tflite';
}

class Routes {
    static final String mainScreen = '/main';
    static final String languageSelectionScreen = '/languageSelection';
}

class InferenceModelConstants {
    static final double confidenceTreshold = 0.9;
    static final int gridSize = 8;
    static final List<String> classes = ['person', 'bird', 'cat', 'cow', 'dog', 'horse', 'sheep', 'aeroplane', 'bicycle', 'boat', 'bus', 'car', 'motorbike', 'train',
        'bottle', 'chair', 'diningtable', 'pottedplant', 'sofa', 'tvmonitor'];
}