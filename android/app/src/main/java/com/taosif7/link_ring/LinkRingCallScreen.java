package com.taosif7.link_ring;

import android.app.KeyguardManager;
import android.app.NotificationManager;
import android.content.Intent;
import android.graphics.drawable.AnimationDrawable;
import android.net.Uri;
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
import com.taosif7.link_ring.models.model_group;
import com.taosif7.link_ring.models.model_link;
import com.taosif7.link_ring.models.model_member;

import org.json.JSONException;
import org.json.JSONObject;

public class LinkRingCallScreen extends AppCompatActivity {

    public static final int CALL_SCREEN_NOTIF_ID = 4654;

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

        // Get notification manager for cancelling call notification
        NotificationManager notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);

        // fetch link, sender and group from data json
        try {
            JSONObject dataObject = new JSONObject(data);
            model_link link = new model_link(dataObject.optJSONObject("link"));
            model_group group = new model_group(dataObject.optJSONObject("group"));
            model_member sender = new model_member(dataObject.optJSONObject("sender"));

            ((TextView) findViewById(R.id.link_text)).setText(link.link);
            ((TextView) findViewById(R.id.sender_name)).setText(sender.name);
            ((TextView) findViewById(R.id.group_name)).setText(group.name);
            ((TextView) findViewById(R.id.group_pic_text)).setText(group.name);
            ((TextView) findViewById(R.id.link_title)).setText(link.name);
            findViewById(R.id.link_title).setVisibility((link.name.equals("null") || link.name.length() == 0) ? View.GONE : View.VISIBLE);

            if (group.iconUrl != null && group.iconUrl.length() > 0) {
                Glide.with(this)
                        .load(group.iconUrl)
                        .into((ImageView) findViewById(R.id.group_pic));
            } else findViewById(R.id.group_pic).setVisibility(View.GONE);

            findViewById(R.id.connect_btn).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    notificationManager.cancel(CALL_SCREEN_NOTIF_ID);
                    Intent linkIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(link.link));
                    startActivity(linkIntent);
                    finish();
                }
            });
            findViewById(R.id.reject_btn).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    notificationManager.cancel(CALL_SCREEN_NOTIF_ID);
                    finish();
                }
            });

        } catch (JSONException e) {
            notificationManager.cancel(CALL_SCREEN_NOTIF_ID);
            e.printStackTrace();
            finish();
            return;
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
