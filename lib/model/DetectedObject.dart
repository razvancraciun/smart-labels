


class DetectedObject {
    Rectangle rectangle;
    String detectedClass;
    double confidence;

    DetectedObject(this.rectangle, this.detectedClass, this.confidence);

    DetectedObject.fromTfliteOutput(element) {
        detectedClass = element['detectedClass'];
        confidence = element['confidenceInClass'];
        rectangle = Rectangle.fromTfliteOutput(element['rect']);
    }

    @override
    String toString() {
    return "x: ${rectangle.x}, y: ${rectangle.y}, w: ${rectangle.width}, h: ${rectangle.height}, class: $detectedClass, confidence: $confidence";
  }
}

class Rectangle {
    double x;
    double y;
    double width;
    double height;

    Rectangle(this.x, this.y, this.width, this.height);

    Rectangle.fromTfliteOutput(element) {
        x = element['x'];
        y = element['y'];
        width = element['w'];
        height = element['h'];
    }
}
