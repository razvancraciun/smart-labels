package com.example.smart_labels2;

import android.content.res.AssetManager;

import androidx.annotation.NonNull;
import android.os.Environment;

import org.tensorflow.lite.Interpreter;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.util.*;
import android.content.res.AssetFileDescriptor;
import android.media.Image;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

    private Interpreter interpreter;

    private static final String CHANNEL = "tflite/interpreter";
    private static final int GRID_SIZE = 7;
    private static final int NUM_CLASSES = 20;
    private static final int N_ANCHORS = 5;
    private static final Double iou_tresh = 0.4;
    private static final Double conf_tresh = 0.55;

    private final List<Double> anchorW = Arrays.asList(1.08, 3.42, 6.63, 9.42, 16.62);
    private final List<Double> anchorH = Arrays.asList(1.19, 4.41, 11.38, 5.11, 10.52);

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("init")) {
                                String initResult = initInterpreter();
                                if (initResult.equals("ok")) {
                                    result.success("Interpreter initialized successfully");
                                } else {
                                    result.error(initResult, "Failed to initialize interpreter", null);
                                }
                                return;
                            }

                            if (call.method.equals("run")) {
                                ArrayList<ArrayList<ArrayList<Double>>> input = call.argument("input");

                                result.success(runInterpreter(input));

                                return;
                            }

                            result.notImplemented();
                        }
                );
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "path/docs")
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("get")) {
                                result.success(Environment.getExternalStorageDirectory().getAbsolutePath().toString());
                                return;
                            }

                            result.notImplemented();
                        }
                );
    }

    private String initInterpreter() {
        try {
            AssetFileDescriptor fileDescriptor = this.getAssets().openFd("tflite/yoloLITE.tflite");
            FileInputStream inputStream = new FileInputStream(fileDescriptor.getFileDescriptor());
            FileChannel fileChannel = inputStream.getChannel();
            long startOffset = fileDescriptor.getStartOffset();
            long declaredLength = fileDescriptor.getDeclaredLength();
            MappedByteBuffer mbb = fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength);
            interpreter = new Interpreter(mbb);
            return "ok";
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    private Double sigmoid(Double x) {
        return (1 / (1 + Math.pow(Math.E, (-1 * x))));
    }

    private Double exp(Double x) {
        return Math.pow(Math.E, x);
    }

    private ArrayList<Double> softmax(ArrayList<Double> predictions) {
        ArrayList<Double> result = new ArrayList(predictions.size());
        Double sum = new Double(0);
        for (Double prediction : predictions) {
            sum += Math.pow(Math.E, prediction);
        }
        for (Double prediction : predictions) {
            result.add(Math.pow(Math.E, prediction) / sum);
        }
        return result;
    }

    private Double max(ArrayList<Double> predictions) {
        Double max = predictions.get(0);
        for (Double prediction : predictions) {
            if (prediction > max) {
                max = prediction;
            }
        }
        return max;
    }

    private Double argmax(ArrayList<Double> predictions) {
        Double max = predictions.get(0);
        Double argmax = new Double(0);
        for (int i = 0; i < predictions.size(); i++) {
            if (predictions.get(i) > max) {
                max = predictions.get(i);
                argmax = new Double(i);
            }
        }
        return argmax;
    }

    private Double calcIOU(Double b1x, Double b1y, Double b1w, Double b1h, Double b2x, Double b2y, Double b2w, Double b2h) {
        if(b1x > b2x + b2w || b2x > b1x + b2w || b1y > b2y + b2w || b2y > b1y + b1w) {
            return 0d;
        }

        Double intersection = Math.min(b1x + b1w - b2x, b2x + b2w - b1x) * Math.min(b1y + b1h - b2y, b2y + b2h - b1y);
        Double union = b1w * b1h + b2w * b2h - intersection;

        return intersection / union;
    }

    private void suppression(ArrayList<ArrayList<Double>> boxes) {
        Collections.sort(boxes, new Comparator<ArrayList<Double>>() {
            @Override
            public int compare(ArrayList<Double> lhs, ArrayList<Double> rhs) {
                // -1 - less than, 1 - greater than, 0 - equal, all inversed for descending
                return lhs.get(0) > rhs.get(0) ? -1 : 1;
            }
        });

        if(boxes.size() > 1) {
            for(int ii=1; ii < boxes.size(); ii++) {
                // ii - proposals
                // jj - accepted
                for(int jj=0; jj < ii; jj++) {
                    ArrayList<Double> box1 = boxes.get(ii);
                    ArrayList<Double> box2 = boxes.get(jj);
                    if(calcIOU(box1.get(1), box1.get(2), box1.get(3), box1.get(4), box2.get(1), box2.get(2), box2.get(3), box2.get(4)) > iou_tresh) {
                        boxes.remove(ii);
                        ii--;
                        break;
                    }
                }
            }
        }
    }

    private ArrayList<ArrayList<Double>> runInterpreter(ArrayList<ArrayList<ArrayList<Double>>> input) {
        float inp[][][][] = new float[1][input.size()][input.get(0).size()][input.get(0).get(0).size()];

        for (int row = 0; row < input.size(); row++) {
            for (int col = 0; col < input.get(row).size(); col++) {
                for (int channel = 0; channel < input.get(row).get(col).size(); channel++) {
                    inp[0][row][col][channel] = input.get(row).get(col).get(channel).floatValue();
                }
            }
        }

        float[][][][] output = new float[1][GRID_SIZE][GRID_SIZE][(NUM_CLASSES + 5) * N_ANCHORS];

        interpreter.run(inp, output);

        ArrayList<ArrayList<Double>> result = new ArrayList<>(GRID_SIZE * GRID_SIZE * N_ANCHORS);
        for (int row = 0; row < GRID_SIZE; row++) {
            for (int col = 0; col < GRID_SIZE; col++) {
                ArrayList<ArrayList<Double>> cell = new ArrayList<>(N_ANCHORS);
                for (int anchor = 0; anchor < N_ANCHORS; anchor++) {
                    ArrayList<Double> prediction = new ArrayList<>(6);
                    Double confidence = sigmoid(new Double(output[0][row][col][anchor * 25 + 4]));
                    Double x = col * 1 / GRID_SIZE + sigmoid(new Double(output[0][row][col][anchor * 25]));
                    Double y = row * 1 / GRID_SIZE + sigmoid(new Double(output[0][row][col][anchor * 25 + 1]));

                    Double w = anchorW.get(anchor) * exp(new Double(output[0][row][col][anchor * 25 + 2])) / GRID_SIZE;
                    Double h = anchorH.get(anchor) * exp(new Double(output[0][row][col][anchor * 25 + 3])) / GRID_SIZE;

                    ArrayList<Double> classPredictions = new ArrayList<Double>(NUM_CLASSES);
                    for (int cls = 0; cls < NUM_CLASSES; cls++) {
                        classPredictions.add(new Double(output[0][row][col][anchor * 25 + 5 + cls]));
                    }
                    classPredictions = softmax(classPredictions);
                    Double detectedClass = argmax(classPredictions);
                    confidence *= max(classPredictions);

                    if(confidence < conf_tresh) {
                        continue;
                    }

                    prediction.add(confidence);
                    prediction.add(x);
                    prediction.add(y);
                    prediction.add(w);
                    prediction.add(h);
                    prediction.add(detectedClass);
                    result.add(prediction);
                }
            }
            suppression(result);
        }

        return result;

    }
}