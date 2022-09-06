package com.bankaletihad.sdk;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;



import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;

import java.util.HashMap;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragment;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.EventChannel.EventSink;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import kyc.ob.BaeInitializer;
//import kyc.Uploader;
//import kyc.ob.BaeInitializer;
//import kyc.FilePicker;
//import kyc.ob.DocumentScanFrontFragment;

public class MainActivity extends FlutterFragmentActivity {
    private static final String UPLOAD_METHOD_CHANNEL = "samples.flutter.io/uploaderMethodChannel";
    private static final String UPLOAD_EVENT_CHANNEL = "samples.flutter.io/uploaderEventChannel";

    private static final String UPLOADER_URL = "https://bl4-dev-02.baelab.net/api/BAF3E974-52AA-7598-FF04-56945EF93500/48EE4790-8AEF-FEA5-FFB6-202374C61700";
    private static EventSink EVENT_SINK = null;
    private final Handler uiThreadHandler = new Handler(Looper.getMainLooper());


    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        GeneratedPluginRegistrant.registerWith(this);
        BaeInitializer di = new BaeInitializer(this, R.raw.iengine);
        di.initialize();
    }


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        flutterEngine.getPlugins().add(new com.baseflow.permissionhandler.PermissionHandlerPlugin());
        FragmentManager fm = this.getSupportFragmentManager();
//        fm.beginTransaction().add(R.id.).commit();
         flutterEngine
            .getPlatformViewsController()
            .getRegistry()
            .registerViewFactory(Views.front.toString(), new NativeViewFactory(fm,         getFlutterEngine()));




        new EventChannel(flutterEngine.getDartExecutor(), UPLOAD_EVENT_CHANNEL).setStreamHandler(
            new EventChannel.StreamHandler() {
                @Override
                public void onListen(Object arguments, EventSink events) {
                    EVENT_SINK = events;
                }
                @Override
                public void onCancel(Object arguments) {
                    EVENT_SINK = null;
                }
            }
        );

        new MethodChannel(flutterEngine.getDartExecutor(), UPLOAD_METHOD_CHANNEL).setMethodCallHandler(
            (call, result) -> {
                if (call.method.equals("initUploader")) {
                    InitUploader();
                } else {
                    result.notImplemented();
                }
            }
        );
    }

    private void InitUploader() {
//        Intent filePickerIntent = new Intent(this, FilePicker.class);
//        String[] mimeTypes = {"image/gif", "application/pdf"};
//        filePickerIntent.putExtra(Intent.EXTRA_MIME_TYPES, mimeTypes);
//        startActivityForResult(filePickerIntent, 0);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == 0) {
            // TODO errors flow
//            EVENT_SINK.success(new HashMap<String, Object>() {{
//                put("data", "");
//                put("uploading", true);
//                put("error", "");
//            }});
//            Uploader fileUploader = new Uploader(this, UPLOADER_URL);
//            fileUploader.addDocument(data.getData());
//            fileUploader.uploadDocuments(uri -> {
//                String result = uri.fileUrl;
//                Log.i("FLUTTER", "do event");
//                uiThreadHandler.post(() ->
//                    EVENT_SINK.success(new HashMap<String, Object>() {{
//                        put("data", result);
//                        put("uploading", false);
//                        put("error", "");
//                    }})
//                );
//            });
        }
    }
}