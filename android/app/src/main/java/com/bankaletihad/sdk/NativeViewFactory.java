package com.bankaletihad.sdk;
import android.content.Context;
import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentManager;

import io.flutter.Log;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import java.util.HashMap;
import java.util.Map;

class NativeViewFactory extends PlatformViewFactory {
    FragmentManager fm;
    private static final String SCAN_EVENT_CHANNEL =  "samples.flutter.io/scannerFrontEventChannel";
    private EventChannel.EventSink EVENT_SINK = null;
    NativeViewFactory(FragmentManager fm, FlutterEngine flutterEngine) {
        super(StandardMessageCodec.INSTANCE);
        this.fm = fm;
        
        new EventChannel(flutterEngine.getDartExecutor(), SCAN_EVENT_CHANNEL).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        Log.i("TAG", "ON LISTEN");
                        EVENT_SINK = events;
                    }
                    @Override
                    public void onCancel(Object arguments) {
                        EVENT_SINK = null;
                    }
                }
        );

    }

    @NonNull
    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = new HashMap<>();
        creationParams.put("fm", fm);
        creationParams.put("eventSink", EVENT_SINK);
        return new DocumentScanFrontView(context, id, creationParams);
    }
}