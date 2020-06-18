
import 'package:flutter/material.dart';

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
    static final String cameraDetect = '/main';
    static final String imageDetect = '/imageDetect';
    static final String languageSelectionScreen = '/languageSelection';
}

class InferenceModelConstants {
    static final int imageSize = 224;
    static final double confidenceTreshold = 0.5;
    static final int nAnchors = 5;
    static final int gridSize = 7;
    static final List<String> classes = ['aeroplane', 'bicycle', 'bird', 'boat', 'bottle', 'bus', 'car', 'cat', 'chair', 'cow', 'dining table',
        'dog', 'horse', 'motorbike', 'person', 'potted plant', 'sheep', 'sofa', 'train', 'tv / monitor'];
}

extension SmartLabelsColors on Colors {
    static final Color gray1 = Color.fromRGBO(64, 69, 82, 1);
    static final Color gray2 = Color.fromRGBO(56, 60, 74, 1);
    static final Color gray3 = Color.fromRGBO(75, 81, 98, 1);
    static final Color lightGray = Color.fromRGBO(124, 129, 140, 1);
    static final Color blue = Color.fromRGBO(82, 148, 226, 1);
}