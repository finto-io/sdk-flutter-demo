package com.bankaletihad.sdk;
import android.content.Context;
import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import androidx.fragment.app.FragmentManager;

import io.flutter.Log;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import java.util.HashMap;
import java.util.Map;

class NativeViewFactory extends PlatformViewFactory {
    FragmentManager fm;
    NativeViewFactory( FragmentManager fm ) {
        super(StandardMessageCodec.INSTANCE);
        this.fm = fm;
    }

    @NonNull
    @Override
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        final Map<String, Object> creationParams = new HashMap<>();
        creationParams.put("fm", fm);
        return new DocumentScanFrontView(context, id, creationParams);
    }
}