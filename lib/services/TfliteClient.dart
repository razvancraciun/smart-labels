


import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:smart_labels2/model/Constants.dart';
import 'package:smart_labels2/model/DetectedObject.dart';
import 'package:smart_labels2/scenes/components/BoundingBox.dart';
import 'package:image/image.dart';
import 'package:image/image.dart' as imLib;

class TfliteClient {
    MethodChannel _methodChannel = const MethodChannel('tflite/interpreter');

    Future<void> init() async {
        await _methodChannel.invokeMethod('init');
    }

    Future<List<DetectedObject>> run(CameraImage image) async {
        int targetWidth = InferenceModelConstants.imageSize;
        int targetHeight = InferenceModelConstants.imageSize;
        Image img = convertYUV420toImageColor(image);

        int x = (img.width - targetWidth) ~/ 2;
        int y = (img.height - targetHeight) ~/ 2;
        img = copyCrop(img,  x, y, targetWidth, targetHeight);


        List<List<List<double>>> input = List.generate(targetWidth, (row) {
            return List.generate(targetHeight, (col) {
                List<double> channels = [];
                channels.add(imLib.getRed(img.getPixel(row, col)) / 255);
                channels.add(imLib.getGreen(img.getPixel(row, col)) / 255);
                channels.add(imLib.getBlue(img.getPixel(row, col)) / 255);
                return channels;
            });
        });

        var output = await _methodChannel.invokeMethod('run', {"input" : input});
        List<DetectedObject> detectedObjects = decodeOutput(output);
        detectedObjects = detectedObjects.map((object) {
//            object.rectangle.x +=  (img.width - targetWidth) / 2 / targetWidth;
//            object.rectangle.y += (img.height - targetHeight) / 2 / targetHeight;
            object.rectangle.height *= (targetHeight / img.height);
            return object;
        }).toList();
        return detectedObjects;
    }

    List<DetectedObject> decodeOutput(List objects) {
        int gridSize = InferenceModelConstants.gridSize;
        List<DetectedObject> result = [];

        result = objects.map( (prediction) {
            double confidence = prediction[0];
            double w = prediction[3];
            double h = prediction[4];
            double x = prediction[1] - w / 2;
            double y = prediction[2] - h / 2;
            String detectedClass = InferenceModelConstants.classes[prediction[5].toInt()];

            return DetectedObject(Rectangle(x,y,w,h), detectedClass, confidence);
        }

        ).toList();

        return result;
    }

    Image convertYUV420toImageColor(CameraImage image) {
        final int width = image.width;
        final int height = image.height;
        final int uvRowStride = image.planes[1].bytesPerRow;
        final int uvPixelStride = image.planes[1].bytesPerPixel;

        const alpha255 = (0xFF << 24);

        final img = Image(width, height); // Create Image buffer

        // Fill image buffer with plane[0] from YUV420_888
        for (int x = 0; x < width; x++) {
            for (int y = 0; y < height; y++) {
                final int uvIndex =
                    uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
                final int index = y * width + x;

                final yp = image.planes[0].bytes[index];
                final up = image.planes[1].bytes[uvIndex];
                final vp = image.planes[2].bytes[uvIndex];
                // Calculate pixel color
                int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
                int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
                    .round()
                    .clamp(0, 255);
                int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
                // color: 0x FF  FF  FF  FF
                //           A   B   G   R
                img.data[index] = alpha255 | (b << 16) | (g << 8) | r;
            }
        }
        return img;
    }

}