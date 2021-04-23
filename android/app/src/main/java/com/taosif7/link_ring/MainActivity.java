package com.taosif7.link_ring;

import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.onesignal.OneSignal;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "com.taosif7.linkring/methodChannel";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Enable verbose OneSignal logging to debug issues if needed.
        OneSignal.setLogLevel(OneSignal.LOG_LEVEL.VERBOSE, OneSignal.LOG_LEVEL.NONE);

        // OneSignal Initialization
        OneSignal.initWithContext(this);
        OneSignal.setAppId("5a6b28d9-dacb-4d81-96cb-496151ab13fd");

    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "getPushToken":
                                    String pushToken = getPushToken();
                                    if (pushToken != null) result.success(getPushToken());
                                    else
                                        result.error("UNAVAILABLE", "PUSH TOKEN UNAVAILABLE", null);
                                    break;
                                default:
                                    result.notImplemented();
                            }
                        }
                );
    }

    public String getPushToken() {
        return OneSignal.getDeviceState().getUserId();
    }
}
