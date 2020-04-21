import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:smart_labels2/model/AppState.dart';
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
    int _frame = 0;
    List<DetectedObject> _detectedObjects = [];
    int _loading = 0;

    @override
    void initState() {
        super.initState();
        print(_appState);
        _cameraController = CameraController(_appState.cameras[0], ResolutionPreset.max);
        _cameraController.initialize().then( (_) {
            if (!mounted) {
                return;
            }
            _cameraController.startImageStream((img) async {
                _frame++;

                if (_frame % 4 != 0) {
                    return;
                }

                var bytes = img.planes.map( (plane) => plane.bytes).toList();
                print(bytes.runtimeType);

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
        return AspectRatio(
            aspectRatio: _cameraController.value.aspectRatio,
            child: Stack(
                children: stackChildren,
            ),
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
            return Text('Tapped on ${boundingBox.detectedClass}. Translation: $translation', style: TextStyle(fontSize: 20),);
        });
    }
}