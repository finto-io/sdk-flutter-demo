package com.bankaletihad.kycsdk;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

public class NativeViewFactory extends PlatformViewFactory {
    FragmentManager fm;
    private static final String SCAN_FRONT_EVENT_CHANNEL = "kyc.sdk/scannerFrontEventChannel";
    private static final String SCAN_BACK_EVENT_CHANNEL = "kyc.sdk/scannerBackEventChannel";
    private static final String SCAN_SELFIE_EVENT_CHANNEL = "kyc.sdk/scannerSelfieEventChannel";
    private static final String SCAN_RECORD_EVENT_CHANNEL = "kyc.sdk/recorderEventChannel";

    private EventChannel.EventSink EVENT_SINK = null;
    private final FlutterEngine flutterEngine;
    private final Views viewType;

    public NativeViewFactory(FragmentManager fm, FlutterEngine flutterEngine, Views viewType) {
        super(StandardMessageCodec.INSTANCE);
        this.fm = fm;
        this.flutterEngine = flutterEngine;
        this.viewType = viewType;
    }

    public void callback(HashMap<String, String> data) {
        final Handler uiThreadHandler = new Handler(Looper.getMainLooper());
        uiThreadHandler.post(() -> EVENT_SINK.success(data)
        );
    }

    public String getEventChannelName() {
        switch (this.viewType) {
            case front: {
                return SCAN_FRONT_EVENT_CHANNEL;
            }
            case back: {
                return SCAN_BACK_EVENT_CHANNEL;
            }
            case selfie: {
                return SCAN_SELFIE_EVENT_CHANNEL;
            }
            case recorder: {
                return SCAN_RECORD_EVENT_CHANNEL;
            }
            default:
                return "";
        }
    }

    @NonNull
    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = new HashMap<>();
        creationParams.put("fm", fm);

        new EventChannel(flutterEngine.getDartExecutor(), this.getEventChannelName()).setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        EVENT_SINK = events;
                    }
                    @Override
                    public void onCancel(Object arguments) {
                        EVENT_SINK = null;
                    }
                }
        );

        MethodChannel channel = new MethodChannel(flutterEngine.getDartExecutor(), this.viewType.toString() + id);

        switch (this.viewType) {
            case front: {
                return new DocumentScanFrontView(context, creationParams, channel, this::callback);
            }
            case back: {
                return new DocumentScanBackView(context, creationParams, channel, this::callback);
            }
            case selfie: {
                return new ScannerSelfieView(context, creationParams, channel, this::callback);
            }
            case recorder: {
                return new VideoRecorderView(context, creationParams, channel, this::callback);
            }
            default:
                return null;
        }
    }
}