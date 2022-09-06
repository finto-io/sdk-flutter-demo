package com.bankaletihad.sdk;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Color;
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
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.platform.PlatformView;
import kyc.BaeError;
import kyc.ob.DocumentScanFrontFragment;


import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentContainerView;
import androidx.fragment.app.FragmentManager;


public class DocumentScanFrontView implements PlatformView, DocumentScanFrontFragment.DocumentScanListener {
    @NonNull
    private final DocumentScanFrontFragment documentFragment;
    private Context context;
    private int layoutID;
    private int idid = 187;
    private FragmentManager fm;
    private EventChannel.EventSink eventSink;
    DocumentScanFrontView(@NonNull Context context, int id, @Nullable Map<String, Object> creationParams) {
        this.fm = (FragmentManager) creationParams.get("fm");
        Log.i("FLUTTER", String.valueOf(id));
        this.context = context;
        this.layoutID = id;
        this.eventSink = (EventChannel.EventSink) creationParams.get("eventSink");


        documentFragment = DocumentScanFrontFragment.newInstance();
        documentFragment.setDocumentScanListener(this);
    }

    @NonNull
    @Override
    public View getView() {
        androidx.fragment.app.FragmentContainerView layout = new androidx.fragment.app.FragmentContainerView(context);
        layout.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.MATCH_PARENT));
        layout.setId(idid);
        layout.setBackgroundColor(Color.GREEN);

        Handler handler = new Handler();

        handler.postDelayed(() -> {

            Log.i("FLUTTER",           ((Activity)context).findViewById(idid).toString());
            fm.beginTransaction().replace(idid, documentFragment).commitAllowingStateLoss();

        }, 2000);


        return layout;
    }

    @Override
    public void dispose() {
    }

    @Override
    public void onDocumentScanFrontSuccess(Bitmap bitmap) {
        Log.i("TAG", "CALLING SUCCESS" + eventSink);
        eventSink.success(new ResultObject("scan_front_success", ""));
    }

    @Override
    public void onDocumentScanFrontFailed(BaeError baeError) {

    }

    @Override
    public void onNoCameraPermission() {

    }
}