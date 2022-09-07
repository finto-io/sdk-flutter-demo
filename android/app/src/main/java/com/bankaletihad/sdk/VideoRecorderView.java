package com.bankaletihad.sdk;

import android.content.Context;
import android.graphics.Color;
import android.os.Handler;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import kyc.BaeError;
import kyc.ob.VideoFragment;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

public class VideoRecorderView implements PlatformView, VideoFragment.VideoRecordListener {
    @NonNull
    private VideoFragment videoFragment;
    private final Context context;
    private final FragmentManager fm;
    private final EventSinkCallBack eventSinkCallBack;
    private LinearLayout layout;

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
        videoFragment.setMaxVideoLength(4);

        channel.setMethodCallHandler(
            (call, result) -> {
                switch (call.method) {
                    case "restart":
                        fm.beginTransaction().remove(videoFragment).commit();
                        videoFragment = new VideoFragment();
                        videoFragment.setVideoRecordListener(this);
                        fm.beginTransaction().add(R.id.video_recorder, videoFragment).commit();
                        Handler handle = new Handler();
                        handle.postDelayed(() -> {
                            layout.findViewById(R.id.recordButton).setVisibility(View.GONE);
                        }, 100);
                        break;
                    case "startRecording":
                        videoFragment.onTouchDown();
                        break;
                    case "endRecording":
                        videoFragment.onTouchUp();
                        break;
                    default:
                        result.notImplemented();
                        break;
                }
            }
        );
    }


    @NonNull
    @Override
    public View getView() {
        layout = new LinearLayout(context);
        layout.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.MATCH_PARENT));
        layout.setId(R.id.video_recorder);
        layout.setBackgroundColor(Color.BLACK);
        layout.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
            @Override
            public void onViewAttachedToWindow(@NonNull View view) {
                fm.beginTransaction().replace(R.id.video_recorder, (Fragment) videoFragment).commitNow();
                Handler handle = new Handler();
                handle.postDelayed(() -> {
                    view.findViewById(R.id.recordButton).setVisibility(View.GONE);
                }, 100);
            }

            @Override
            public void onViewDetachedFromWindow(@NonNull View view) {
            }
        });

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
        eventSinkCallBack.run(new HashMap<String, String>() {{
            put("type", "record_loading_started");
            put("data", "");
        }});
    }

}