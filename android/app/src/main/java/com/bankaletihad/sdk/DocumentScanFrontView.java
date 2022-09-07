package com.bankaletihad.sdk;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Handler;
import android.os.Looper;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import kyc.BaeError;
import kyc.ob.DocumentScanFrontFragment;

import androidx.fragment.app.FragmentManager;

public class DocumentScanFrontView implements PlatformView, DocumentScanFrontFragment.DocumentScanListener {
    @NonNull
    private final DocumentScanFrontFragment documentFragment;
    private Context context;
    private FragmentManager fm;
    private EventSinkCallBack eventSinkCallBack;
    interface EventSinkCallBack {
        void run(HashMap<String, String> res);
    }

    DocumentScanFrontView(
            @NonNull Context context,
            int id,
            @Nullable Map<String,Object> creationParams,
            MethodChannel channel,
            EventSinkCallBack eventSinkCallBack
    ) {
        this.fm = (FragmentManager) creationParams.get("fm");
        this.context = context;

        this.eventSinkCallBack = eventSinkCallBack;
        documentFragment = DocumentScanFrontFragment.newInstance();
        documentFragment.setDocumentScanListener(this);

        channel.setMethodCallHandler(
            (call, result) -> {
                if (call.method.equals("initialize")) {
                    Handler handler = new Handler(Looper.getMainLooper());
                    handler.postDelayed(() -> {
                        fm.beginTransaction().replace(R.id.scan_front, documentFragment).commit();
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
        layout.setId(R.id.scan_front);
        layout.setBackgroundColor(Color.BLACK);
        return layout;
    }

    @Override
    public void dispose() {
    }

    @Override
    public void onDocumentScanFrontSuccess(Bitmap bitmap) {

        eventSinkCallBack.run(new HashMap<String, String>() {{
            put("type", "scan_front_success");
            put("data", "");
        }});
    }

    @Override
    public void onDocumentScanFrontFailed(BaeError baeError) {
        eventSinkCallBack.run(new HashMap<String, String>() {{
            put("type", "scan_front_failed");
            put("data", baeError.getMessage());
        }});
    }

    @Override
    public void onNoCameraPermission() {

    }
}