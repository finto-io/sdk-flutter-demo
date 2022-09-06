package com.bankaletihad.sdk;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentManager;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import kyc.BaeError;
import kyc.ob.SelfieAutoCaptureFragment;


public class ScannerSelfieView implements PlatformView, SelfieAutoCaptureFragment.SelfieListener {
    @NonNull
    private final SelfieAutoCaptureFragment documentFragment;
    private Context context;
    private int id = 3;
    private FragmentManager fm;
    private EventSinkCallBack eventSinkCallBack;

    interface EventSinkCallBack {
        void run(HashMap<String, String> res);
    }

    ScannerSelfieView(
            @NonNull Context context,
            int id,
            @Nullable Map<String,Object> creationParams,
            MethodChannel channel,
            EventSinkCallBack eventSinkCallBack
    ) {
        this.fm = (FragmentManager) creationParams.get("fm");
        this.context = context;

        this.eventSinkCallBack = eventSinkCallBack;
        documentFragment = SelfieAutoCaptureFragment.newInstance();
        documentFragment.setLivelinessListener(this);

        channel.setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("initialize")) {
                        Handler handler = new Handler();
                        handler.postDelayed(() -> {
                            fm.beginTransaction().replace(this.id, documentFragment).commit();
                        }, 1000);
                    } else {
                        result.notImplemented();
                    }
                }
        );
    }

    @NonNull
    @Override
    public View getView() {
        androidx.fragment.app.FragmentContainerView layout = new androidx.fragment.app.FragmentContainerView(context);
        layout.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.MATCH_PARENT));
        layout.setId(this.id);
        return layout;
    }

    @Override
    public void dispose() {
    }

    @Override
    public void onSelfieCaptured(Bitmap bitmap) {
        eventSinkCallBack.run(new HashMap<String, String>() {{
            put("type", "scan_selfie_success");
            put("data", "");
        }});
    }

    @Override
    public void onSelfieFailed(BaeError baeError) {
        eventSinkCallBack.run(new HashMap<String, String>() {{
            put("type", "scan_selfie_failed");
            put("data", baeError.getMessage());
        }});
    }

    @Override
    public void onNoCameraPermission() {

    }

}