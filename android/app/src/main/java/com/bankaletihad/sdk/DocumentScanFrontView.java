package com.bankaletihad.sdk;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Map;
import java.util.Timer;


import io.flutter.Log;
import io.flutter.plugin.platform.PlatformView;


import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentContainerView;
import androidx.fragment.app.FragmentManager;


public class DocumentScanFrontView implements PlatformView {
    @NonNull
    private final SelfieCapture documentFragment;
    private Context context;
    private int layoutID;
    private int idid = 1234321;
    private FragmentManager fm;
    DocumentScanFrontView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        this.fm = (FragmentManager) creationParams.get("fm");
        this.context = context;
        this.layoutID = id;
        documentFragment = SelfieCapture.newInstance();
//        documentFragment.setDocumentScanListener(this);
    }

    @NonNull
    @Override
    public View getView() {

        androidx.fragment.app.FragmentContainerView layout = new androidx.fragment.app.FragmentContainerView(context);
        layout.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.MATCH_PARENT));
        int interval = 1000; // 1 Second
        Handler handler = new Handler();
        Runnable runnable = ()-> {
            fm.beginTransaction().add(idid, documentFragment).commit();

        };

        handler.postDelayed(runnable, interval);
        handler.postDelayed(()->{

        }, interval + 1000);

        layout.setId(idid);
        return layout;
    }

    @Override
    public void dispose() {
    }

}