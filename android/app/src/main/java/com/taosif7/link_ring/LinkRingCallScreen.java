package com.taosif7.link_ring;

import android.app.KeyguardManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.graphics.drawable.AnimationDrawable;
import android.os.Build;
import android.os.Bundle;
import android.os.PowerManager;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.bumptech.glide.Glide;
import com.taosif7.link_ring.models.model_callNotification;

import org.json.JSONException;
import org.json.JSONObject;

import static com.taosif7.link_ring.CallBroadcastReceiver.ACTION_CALL_CONNECT;
import static com.taosif7.link_ring.CallBroadcastReceiver.ACTION_CALL_HIDE_UI;
import static com.taosif7.link_ring.CallBroadcastReceiver.ACTION_CALL_IGNORE;

public class LinkRingCallScreen extends AppCompatActivity {

    BroadcastReceiver callActionsReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            String action = intent.getAction();
            if (action.equals(ACTION_CALL_HIDE_UI)) {
                finish();
            }
        }
    };

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Get data from intent, if not provided, finish return
        String data = getIntent().getStringExtra("data");
        if (data == null) {
            finish();
            return;
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true);
            setTurnScreenOn(true);
        }

        getWindow().addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD | WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON | WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED);

        PowerManager powerManager = (PowerManager) getSystemService(POWER_SERVICE);
        PowerManager.WakeLock wakeLock = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK
                        | PowerManager.ACQUIRE_CAUSES_WAKEUP
                        | PowerManager.ON_AFTER_RELEASE,
                "MyApp::" + "xxx");
        wakeLock.acquire(10000);

        // Unlock keyguard
        KeyguardManager keyguardManager = (KeyguardManager) getSystemService(KEYGUARD_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            keyguardManager.requestDismissKeyguard(this, new KeyguardManager.KeyguardDismissCallback() {
                @Override
                public void onDismissSucceeded() {
                    super.onDismissSucceeded();
                }

                @Override
                public void onDismissCancelled() {
                    super.onDismissCancelled();
                }

                @Override
                public void onDismissError() {
                    super.onDismissError();
                }
            });
        }

        setContentView(R.layout.call_screen);

        // set animation for background
        AnimationDrawable animationDrawable = (AnimationDrawable) findViewById(R.id.call_screen_bg).getBackground();
        animationDrawable.setEnterFadeDuration(1000);
        animationDrawable.setExitFadeDuration(2000);
        animationDrawable.start();

        // fetch link, sender and group from data json
        try {
            JSONObject dataObject = new JSONObject(data);
            model_callNotification callData = new model_callNotification(dataObject);

            ((TextView) findViewById(R.id.link_text)).setText(callData.link.link);
            ((TextView) findViewById(R.id.sender_name)).setText(callData.sender.name);
            ((TextView) findViewById(R.id.group_name)).setText(callData.group.name);
            ((TextView) findViewById(R.id.group_pic_text)).setText(callData.group.name);
            ((TextView) findViewById(R.id.link_title)).setText(callData.link.name);
            findViewById(R.id.link_title).setVisibility(!callData.link.hasName ? View.GONE : View.VISIBLE);

            if (callData.group.iconUrl != null && callData.group.iconUrl.length() > 0) {
                Glide.with(this)
                        .load(callData.group.iconUrl)
                        .into((ImageView) findViewById(R.id.group_pic));
            } else findViewById(R.id.group_pic).setVisibility(View.GONE);

            findViewById(R.id.connect_btn).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    Intent callHideIntent = new Intent(LinkRingCallScreen.this, CallBroadcastReceiver.class);
                    callHideIntent.setAction(ACTION_CALL_CONNECT);
                    callHideIntent.putExtra("data", data);
                    sendBroadcast(callHideIntent);
                }
            });
            findViewById(R.id.reject_btn).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    // Send broadcast intent for
                    Intent callHideIntent = new Intent(LinkRingCallScreen.this, CallBroadcastReceiver.class);
                    callHideIntent.setAction(ACTION_CALL_IGNORE);
                    callHideIntent.putExtra("data", data);
                    sendBroadcast(callHideIntent);
                }
            });

        } catch (JSONException e) {
            e.printStackTrace();
            finish();
        }
    }

    @Override
    protected void onStart() {
        super.onStart();
        IntentFilter filter = new IntentFilter();
        filter.addAction(ACTION_CALL_HIDE_UI);
        registerReceiver(callActionsReceiver, filter);
    }

    @Override
    protected void onStop() {
        unregisterReceiver(callActionsReceiver);
        super.onStop();
    }
}
