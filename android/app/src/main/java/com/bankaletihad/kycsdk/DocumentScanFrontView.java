package com.bankaletihad.kycsdk;

import android.content.Context;
import android.graphics.Bitmap;
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

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.bankaletihad.sdk.R;


public class DocumentScanFrontView implements PlatformView, DocumentScanFrontFragment.DocumentScanListener {
    @NonNull
    private DocumentScanFrontFragment documentFrontFragment;
    private final Context context;
    private final FragmentManager fm;
    private final EventSinkCallBack eventSinkCallBack;
    interface EventSinkCallBack {
        void run(HashMap<String, String> res);
    }


    DocumentScanFrontView(
            @NonNull Context context,
            @Nullable Map<String, Object> creationParams,
            MethodChannel channel,
            EventSinkCallBack eventSinkCallBack
    ) {
        this.fm = (FragmentManager) creationParams.get("fm");
        this.context = context;

        this.eventSinkCallBack = eventSinkCallBack;
        documentFrontFragment = DocumentScanFrontFragment.newInstance();
        documentFrontFragment.setDocumentScanListener(this);

        channel.setMethodCallHandler(
            (call, result) -> {
              if (call.method.equals("restart")) {
                    fm.beginTransaction().remove(documentFrontFragment).commit();
                    documentFrontFragment = DocumentScanFrontFragment.newInstance();
                    documentFrontFragment.setDocumentScanListener(this);
                    fm.beginTransaction().replace(R.id.scan_front, documentFrontFragment).commit();
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
        layout.addOnAttachStateChangeListener(new View.OnAttachStateChangeListener() {
            @Override
            public void onViewAttachedToWindow(@NonNull View view) {
                fm.beginTransaction().replace(R.id.scan_front, (Fragment) documentFrontFragment).commitNow();
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