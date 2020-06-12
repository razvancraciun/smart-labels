

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:smart_labels2/model/DetectedObject.dart';

class BoundingBoxDelegate {
    void didTapBoundingBox(BoundingBox box) {}
}

// ignore: must_be_immutable
class BoundingBox extends StatelessWidget {
    final DetectedObject _detectedObject;

    BoundingBox(this._detectedObject);
    BoundingBoxDelegate delegate;
    String get detectedClass {
        return _detectedObject.detectedClass;
    }

    @override
    Widget build(BuildContext context) {
        final  size = MediaQuery.of(context).size;

        var width = size.width * _detectedObject.rectangle.width;
        var height = size.height * _detectedObject.rectangle.height;
        var top = size.height * (_detectedObject.rectangle.y);
        var left = size.width * (_detectedObject.rectangle.x);

        Widget objectContainer = Container(
            child: Align(
                alignment: Alignment.center,
                child: Text(
                   '${_detectedObject.detectedClass}-${_detectedObject.confidence.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        backgroundColor: _colorForClass(_detectedObject.detectedClass),
                        decoration: TextDecoration.none
                    ),

                ),

            ),
            decoration:  BoxDecoration(
                border: Border.all(color: _colorForClass(_detectedObject.detectedClass), width: 3.0),
            ),
        );

        return Positioned(
                child: GestureDetector(
                    child: objectContainer,
                    onTap: () => delegate?.didTapBoundingBox(this),
                ),
                top: top,
                left: left,
                width: width,
                height: height,
        );
    }

    Color _colorForClass(String cls) {
        switch (cls) {
            case 'person':
                return Colors.pink;
            case 'bird':
                return Colors.indigo;
            case 'cat':
                return Colors.lightBlue;
            case 'cow':
                return Colors.green;
            case 'dog':
                return Colors.deepPurple;
            case 'horse':
                return Colors.deepOrange;
            case 'chair':
                return Colors.brown;
            default:
                return Colors.black;
                //, 'sheep', 'aeroplane', 'bicycle', 'boat', 'bus', 'car', 'motorbike', 'train',
                //'bottle', 'chair', 'diningtable', 'pottedplant', 'sofa', 'tvmonitor'
        };
    }
}