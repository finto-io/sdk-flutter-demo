package com.bankaletihad.sdk;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import kyc.BaeError;
import kyc.ob.SelfieAutoCaptureFragment;


public class ScannerSelfieView implements PlatformView, SelfieAutoCaptureFragment.SelfieListener {
    @NonNull
    private SelfieAutoCaptureFragment selfieFragment;
    private final Context context;
    private final FragmentManager fm;
    private final EventSinkCallBack eventSinkCallBack;

    interface EventSinkCallBack {
        void run(HashMap<String, String> res);
    }

    ScannerSelfieView(
            @NonNull Context context,
            int id,
            @Nullable Map<String, Object> creationParams,
            MethodChannel channel,
            EventSinkCallBack eventSinkCallBack
    ) {
        this.fm = (FragmentManager) creationParams.get("fm");
        this.context = context;

        this.eventSinkCallBack = eventSinkCallBack;
        selfieFragment = SelfieAutoCaptureFragment.newInstance();
        selfieFragment.setLivelinessListener(this);

        channel.setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("initialize")) {

                    } else if (call.method.equals("restart")) {

                        fm.beginTransaction().remove(selfieFragment).commit();
                        selfieFragment = SelfieAutoCaptureFragment.newInstance();
                        selfieFragment.setLivelinessListener(this);
                        fm.beginTransaction().add(R.id.take_selfie, selfieFragment).commit();

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
        layout.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
        layout.setId(R.id.take_selfie);
        layout.setBackgroundColor(Color.BLACK);
        layout.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
            @Override
            public void onViewAttachedToWindow(@NonNull View view) {
                fm.beginTransaction().replace(R.id.scan_front, (Fragment) selfieFragment).commitNow();
            }

            @Override
            public void onViewDetachedFromWindow(@NonNull View view) {
                Log.i("TAG", "onViewDetachedFromWindow");
            }
        });
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