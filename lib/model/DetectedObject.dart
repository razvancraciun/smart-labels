


class DetectedObject {
    _Rectangle rectangle;
    String detectedClass;
    double confidence;

    DetectedObject(this.rectangle, this.detectedClass, this.confidence);

    DetectedObject.fromTfliteOutput(element) {
        detectedClass = element['detectedClass'];
        confidence = element['confidenceInClass'];
        rectangle = _Rectangle.fromTfliteOutput(element['rect']);
    }
}

class _Rectangle {
    double x;
    double y;
    double width;
    double height;

    _Rectangle(this.x, this.y, this.width, this.height);

    _Rectangle.fromTfliteOutput(element) {
        x = element['x'];
        y = element['y'];
        width = element['w'];
        height = element['h'];
    }
}
