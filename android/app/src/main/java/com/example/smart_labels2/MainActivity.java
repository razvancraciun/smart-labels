package com.example.smart_labels2;

import android.content.res.AssetManager;

import androidx.annotation.NonNull;

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
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import android.content.res.AssetFileDescriptor;
import android.media.Image;


public class MainActivity extends FlutterActivity {

    private Interpreter interpreter;

    private static final String CHANNEL = "tflite/interpreter";
    private static final int GRID_SIZE = 8;
    private static final int NUM_CLASSES = 20;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("init")) {
                                String initResult = initInterpreter();
                                if (initResult.equals("ok")) {
                                    result.success("Interpreter initialized successfully");
                                } else {
                                    result.error(initResult, null, null);
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
    }

    private String initInterpreter() {
        try {
            AssetFileDescriptor fileDescriptor = this.getAssets().openFd("save0419-1241.tflite");
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

    private ArrayList<ArrayList<Double>> runInterpreter(ArrayList<ArrayList<ArrayList<Double>>> input) {
        float inp[][][][] = new float[1][input.size()][input.get(0).size()][input.get(0).get(0).size()];

        for(int row = 0; row < input.size(); row++) {
            for(int col = 0; col < input.get(row).size(); col++) {
                for(int channel = 0; channel < input.get(row).get(col).size(); channel++) {
                    inp[0][row][col][channel] = input.get(row).get(col).get(channel).floatValue();
                }
            }
        }

        float[][][] output = new float[1][GRID_SIZE * GRID_SIZE][NUM_CLASSES + 5];

        interpreter.run(inp, output);

        ArrayList<ArrayList<Double>> result = new ArrayList<>(GRID_SIZE * GRID_SIZE);
        for(int i=0; i<GRID_SIZE * GRID_SIZE; i++) {
            ArrayList<Double> cell = new ArrayList<Double>(NUM_CLASSES + 5);
            for (int j = 0; j < NUM_CLASSES + 5; j++) {
                output[0][i][j] = output[0][i][j];
                cell.add(new Double(output[0][i][j]));
            }
            result.add(cell);
        }


        return result;
    }
}
