package com.bankaletihad.sdk;
import android.content.Context;
import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentManager;

import io.flutter.Log;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import java.util.HashMap;
import java.util.Map;

class NativeViewFactory extends PlatformViewFactory {
    FragmentManager fm;
    private static final String SCAN_EVENT_CHANNEL =  "samples.flutter.io/scannerFrontEventChannel";
    private static final String UPLOAD_METHOD_CHANNEL =  "samples.flutter.io/12312";
    private EventChannel.EventSink EVENT_SINK = null;
    private FlutterEngine flutterEngine;
    NativeViewFactory(FragmentManager fm, FlutterEngine flutterEngine) {
        super(StandardMessageCodec.INSTANCE);
        this.fm = fm;
        this.flutterEngine = flutterEngine;
        Log.i("NativeViewFactory", "NativeViewFactory");


    }
    public void callback(HashMap<String, String> data) {
        Log.i("TAG", data.toString());
        Log.i("TAG", EVENT_SINK + "");
        EVENT_SINK.success(data);
    }



    @NonNull
    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = new HashMap<>();
        creationParams.put("fm", fm);
        Log.e("NativeViewFactory", "NativeViewFactory");

        new EventChannel(flutterEngine.getDartExecutor(), SCAN_EVENT_CHANNEL).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        Log.i("TAG", "ON LISTEN");
                        EVENT_SINK = events;
                    }
                    @Override
                    public void onCancel(Object arguments) {
                        Log.i("TAG", "onCancel");
                        EVENT_SINK = null;
                    }
                }
        );

        new MethodChannel(flutterEngine.getDartExecutor(), UPLOAD_METHOD_CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("initUploader")) {
//                        InitUploader();
                    } else {
                        result.notImplemented();
                    }
                }
        );


        return new DocumentScanFrontView(context, id, creationParams, this::callback);
    }


}