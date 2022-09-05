package com.bankaletihad.sdk;


import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.camera.view.PreviewView;

import com.innovatrics.dot.document.autocapture.DocumentAutoCaptureConfiguration;
import com.innovatrics.dot.document.autocapture.DocumentAutoCaptureDetection;
import com.innovatrics.dot.document.autocapture.DocumentAutoCaptureFragment;
import com.innovatrics.dot.document.autocapture.DocumentAutoCaptureResult;
import com.innovatrics.dot.face.autocapture.FaceAutoCaptureFragment;


public class SelfieCapture extends DocumentAutoCaptureFragment {
    public View g;
    private DocumentScanListener documentScanListener;
    public interface DocumentScanListener {
        void onDocumentScanBackSuccess(Bitmap bitmap);

        void onNoCameraPermission();
    }
    private ProgressBar progressBar;
    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        RelativeLayout layout = new RelativeLayout(getContext());
        progressBar = new ProgressBar(getContext(),null,android.R.attr.progressBarStyleLarge);
        progressBar.setIndeterminate(true);
//        progressBar.setVisibility(View.GONE);
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(100,100);
        params.addRule(RelativeLayout.CENTER_IN_PARENT);
        View view =  super.onCreateView(inflater, container, savedInstanceState);
        layout.addView(view);
        layout.addView(progressBar,params);
        Log.i("TAG", view.toString());
        g = view;
        return layout;
    }

    @Override
    public void onViewCreated(View view, Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
//        TextView tw = view.findViewById(R.id.instruction);
//        PreviewView preview = view.findViewById(R.id.preview);
        
//        preview.bringToFront();


    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.i("TAG", "ON CREATE");
        start();
    }
    public void sss(){
        start();
    }

    @Override
    protected void onCandidateSelectionStarted() { }

    @Override
    protected void onCaptured(@NonNull DocumentAutoCaptureResult documentAutoCaptureResult) {

    }

    @Override
    protected void onDetected(@NonNull DocumentAutoCaptureDetection documentAutoCaptureDetection) { }

    @Override
    protected void onNoCameraPermission() { this.documentScanListener.onNoCameraPermission(); }

    public static SelfieCapture newInstance(){
        DocumentAutoCaptureConfiguration documentAutoCaptureConfiguration = new DocumentAutoCaptureConfiguration.Builder()
                .detectionLayerVisible(true)
                .mrzReadingEnabled(true)
                .build();
        Bundle arguments = new Bundle();
        arguments.putSerializable(DocumentAutoCaptureFragment.CONFIGURATION, documentAutoCaptureConfiguration);
        SelfieCapture fragment = new SelfieCapture();
        fragment.setArguments(arguments);
        return fragment;
    }


    public void setDocumentScanListener(DocumentScanListener documentScanListener) {
        this.documentScanListener = documentScanListener;
    }
}