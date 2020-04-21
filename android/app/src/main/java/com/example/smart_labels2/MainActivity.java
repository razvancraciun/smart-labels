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
                                result.success(runInterpreter(call.argument("image")));
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

    private String runInterpreter(ArrayList<Integer> input_data) {
        float input[][] = new float[1][input_data.size()];

        float[][][] output = new float[1][GRID_SIZE * GRID_SIZE][NUM_CLASSES + 5];

        interpreter.run(input, output);
        System.out.println(output);

        return "";
    }
}
