

import 'dart:math';

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
        final deviceRatio = size.width / size.height;

        var left = size.width * _detectedObject.rectangle.x;

        var top = size.height * _detectedObject.rectangle.y;
        var width = size.width * _detectedObject.rectangle.width;
        var height = size.height * _detectedObject.rectangle.height;

        Widget objectContainer = Container(
            child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                    _detectedObject.detectedClass,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        backgroundColor: Colors.black,
                        decoration: TextDecoration.none
                    ),

                ),

            ),
            decoration:  BoxDecoration(
                border: Border.all(color: Colors.black, width: 3.0),
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

}