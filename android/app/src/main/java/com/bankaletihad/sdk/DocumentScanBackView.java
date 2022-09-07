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
import kyc.ob.DocumentScanBackFragment;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

public class DocumentScanBackView implements PlatformView, DocumentScanBackFragment.DocumentScanListener {
    @NonNull
    private DocumentScanBackFragment documentBackFragment;
    private final Context context;
    private final FragmentManager fm;
    private final EventSinkCallBack eventSinkCallBack;

    interface EventSinkCallBack {
        void run(HashMap<String, String> res);
    }

    DocumentScanBackView(
            @NonNull Context context,
            int id,
            @Nullable Map<String,Object> creationParams,
            MethodChannel channel,
            EventSinkCallBack eventSinkCallBack
    ) {
        this.fm = (FragmentManager) creationParams.get("fm");
        this.context = context;
        this.eventSinkCallBack = eventSinkCallBack;
        documentBackFragment = DocumentScanBackFragment.newInstance();
        documentBackFragment.setDocumentScanListener(this);

        channel.setMethodCallHandler(
            (call, result) -> {
                if (call.method.equals("restart")) {
                    fm.beginTransaction().remove(documentBackFragment).commit();
                    documentBackFragment = DocumentScanBackFragment.newInstance();
                    documentBackFragment.setDocumentScanListener(this);
                    fm.beginTransaction().add(R.id.scan_back, documentBackFragment).commit();
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
        layout.setId(R.id.scan_back);
        layout.setBackgroundColor(Color.BLACK);
        layout.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
            @Override
            public void onViewAttachedToWindow(@NonNull View view) {
                fm.beginTransaction().replace(R.id.scan_front, (Fragment) documentBackFragment).commitNow();
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
    public void onDocumentScanBackSuccess(Bitmap bitmap) {
        eventSinkCallBack.run(new HashMap<String, String>() {{
            put("type", "scan_back_success");
            put("data", "");
        }});
    }

    @Override
    public void onDocumentScanBackFailed(BaeError baeError) {
        eventSinkCallBack.run(new HashMap<String, String>() {{
            put("type", "scan_back_failed");
            put("data", baeError.getMessage());
        }});
    }

    @Override
    public void onNoCameraPermission() {

    }
}