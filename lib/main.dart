import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_labels2/model/Constants.dart';
import 'package:smart_labels2/scenes/LanguageSelectionScreen.dart';
import 'package:smart_labels2/services/ApiClient.dart';
import 'package:smart_labels2/services/TfliteClient.dart';
import 'package:camera/camera.dart';
import 'package:smart_labels2/scenes/MainScreen.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:hive/hive.dart';
import 'package:smart_labels2/model/AppState.dart';
import 'model/Constants.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    Directory documentDir = await getApplicationDocumentsDirectory();

    Hive.init(documentDir.path);
    await Hive.openBox(HiveKeys.configBox);

    List<CameraDescription> cameras;
    try {
        cameras = await availableCameras();
    } on CameraException catch (e) {
        print('Error code ${e.code}. Description: ${e.description} ');
    }

    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    await remoteConfig.fetch(expiration: const Duration(seconds: 0));
    await remoteConfig.activateFetched();

    ApiClient apiClient = ApiClient();
    apiClient.init(remoteConfig.getString(ApiConstants.remoteConfigTranslateKey));

    TfliteClient tfliteClient = TfliteClient();
    await tfliteClient.init();

    AppState appState = AppState();
    appState.init(tfliteClient, cameras);

    runApp(SmartLabelsApp());
}

class SmartLabelsApp extends StatelessWidget {
    SmartLabelsApp();

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            initialRoute: Routes.languageSelectionScreen,
            routes: {
                Routes.languageSelectionScreen : (context) => LanguageSelectionScreen(),
                Routes.cameraDetect : (context) => MainScreen(),
            },
        );
    }
}