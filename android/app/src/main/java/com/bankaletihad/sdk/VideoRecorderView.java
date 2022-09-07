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

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import kyc.BaeError;
import kyc.ob.VideoFragment;

import androidx.fragment.app.FragmentManager;

public class VideoRecorderView implements PlatformView, VideoFragment.VideoRecordListener {
    @NonNull
    private VideoFragment videoFragment;
    private final Context context;
    private final FragmentManager fm;
    private final EventSinkCallBack eventSinkCallBack;

    interface EventSinkCallBack {
        void run(HashMap<String, String> res);
    }

    VideoRecorderView(
            @NonNull Context context,
            int id,
            @Nullable Map<String,Object> creationParams,
            MethodChannel channel,
            EventSinkCallBack eventSinkCallBack
    ) {
        this.fm = (FragmentManager) creationParams.get("fm");
        this.context = context;

        this.eventSinkCallBack = eventSinkCallBack;
        videoFragment = new VideoFragment();
        videoFragment.setVideoRecordListener(this);

        channel.setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("initialize")) {
                        Handler handler = new Handler(Looper.getMainLooper());
                        handler.postDelayed(() -> {
                            fm.beginTransaction().add(R.id.video_recorder, videoFragment).commit();
                        }, 100);
                    } else if (call.method.equals("restart")) {
                        Handler handler = new Handler(Looper.getMainLooper());
                        handler.postDelayed(() -> {
                            fm.beginTransaction().remove(videoFragment).commit();

                        }, 100);
                        handler.postDelayed(() -> {
                            videoFragment = new VideoFragment();
                            videoFragment.setVideoRecordListener(this);
                            fm.beginTransaction().add(R.id.video_recorder, videoFragment).commit();
                        }, 100);
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
        layout.setId(R.id.video_recorder);
        layout.setBackgroundColor(Color.BLACK);
        return layout;
    }

    @Override
    public void dispose() {
    }

    @Override
    public void onVideoRecordSuccess(String url) {
        eventSinkCallBack.run(new HashMap<String, String>() {{
            put("type", "record_success");
            put("data", url);
        }});
    }

    @Override
    public void onVideoRecordFailed(BaeError baeError) {
        eventSinkCallBack.run(new HashMap<String, String>() {{
            put("type", "record_failed");
            put("data", baeError.getMessage());
        }});
    }

    @Override
    public void onVideoRecordLoadingStarted() {

    }

}