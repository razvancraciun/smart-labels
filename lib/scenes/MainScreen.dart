import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:smart_labels2/model/AppState.dart';
import 'package:smart_labels2/model/Constants.dart';
import 'package:smart_labels2/model/DetectedObject.dart';
import 'package:smart_labels2/services/ApiClient.dart';
import 'package:smart_labels2/scenes/components/BoundingBox.dart';
import 'package:hive/hive.dart';
import 'package:smart_labels2/model/Language.dart';

class MainScreen extends StatefulWidget {
    @override
    _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> implements BoundingBoxDelegate {
    final AppState _appState = AppState();
    final ApiClient apiClient = ApiClient();

    CameraController _cameraController;
    List<DetectedObject> _detectedObjects = [];
    CameraImage displayedImage;
    int _loading = 0;
    bool _interpreter_busy = false;

    @override
    void initState() {
        super.initState();
        _cameraController = CameraController(_appState.cameras[0], ResolutionPreset.low);
        _cameraController.initialize().then( (_) async {
            if (!mounted) {
                return;
            }
            await Future.delayed(Duration(milliseconds : 200));
            _cameraController.startImageStream((img) {
                runInference(img);
            });
        });
    }

    @override
    void dispose() {
        _cameraController?.dispose();
        super.dispose();
    }

    @override
    Widget build(BuildContext context) {
        if(!_cameraController.value.isInitialized) {
            return Container();
        }

        List<Widget> stackChildren = [];

        stackChildren.add(CameraPreview(_cameraController));

        List<BoundingBox> boundingBoxes = _detectedObjects.map( (obj) {return BoundingBox(obj); }).toList();
        boundingBoxes.forEach( (box) => box.delegate = this);
        stackChildren.addAll(boundingBoxes);

        if(_loading > 0) {
            stackChildren.add(Center(
                child: CircularProgressIndicator(
                    backgroundColor: Colors.black,
                    strokeWidth: 5,
                ),
            ));
        }

        final size = MediaQuery.of(context).size;
        final deviceRatio = size.width / size.height;
        return Scaffold(
            appBar: AppBar(
                title: Text("Smart Labels"),
                backgroundColor: SmartLabelsColors.gray2,
            ),
            body: Center(
                child: Container(
                    child:  AspectRatio(
                        aspectRatio: _cameraController.value.aspectRatio,
                        child: Stack(
                            children: stackChildren,
                        )
                    ),
                    ),
            ),
            backgroundColor: Colors.black,

        );
    }

    void didTapBoundingBox(BoundingBox boundingBox) async {
        Box languageBox = Hive.box(_appState.selectedLanguage.code);
        String translation = languageBox.get(boundingBox.detectedClass);
        if(translation == null) {
            setState(() {
            _loading++;
            });
            translation = await apiClient.translate(boundingBox.detectedClass);
            languageBox.put(boundingBox.detectedClass, translation);
            setState(() {
            _loading--;
            });
        }
        showModalBottomSheet(context: context, builder: (context) {
            return Container(
                child: Text('Tapped on "${boundingBox.detectedClass}".\n Translation in ${_appState.selectedLanguage.description}: \n"$translation"',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                    textAlign: TextAlign.center,
                    maxLines: 3,),
                color: SmartLabelsColors.gray3,
            );
        });
    }

    void runInference(CameraImage image) async {
        if(_interpreter_busy) {
            return;
        }
        _interpreter_busy = true;
        List<DetectedObject> detectedObjects = await _appState.tfliteClient.run(image);
        _interpreter_busy = false;
        setState(() {
          _detectedObjects = detectedObjects;
        });
    }
}