package com.taosif7.link_ring;

import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;

import androidx.annotation.ColorRes;
import androidx.core.app.NotificationCompat;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.JsonObjectRequest;
import com.android.volley.toolbox.Volley;
import com.taosif7.link_ring.models.model_callNotification;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.net.MalformedURLException;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

public class CallBroadcastReceiver extends BroadcastReceiver {

    public static final int CALL_SCREEN_NOTIF_ID = 4654;
    public static final int CALL_RING_DURATION_SECONDS = 40;

    public static final String ACTION_CALL_SHOW_UI = "LinkRing.ShowCallNotification";
    public static final String ACTION_CALL_HIDE_UI = "LinkRing.HideCallNotification";
    public static final String ACTION_CALL_CONNECT = "LinkRing.ConnectCall";
    public static final String ACTION_CALL_IGNORE = "LinkRing.IgnoreCall";

    @Override
    public void onReceive(Context context, Intent intent) {

        String action = intent.getAction();
        if (action.equals(ACTION_CALL_SHOW_UI)) {

            try {
                ShowCallNotification(context, intent);
            } catch (JSONException | IOException | ExecutionException | InterruptedException e) {
                e.printStackTrace();
            }

        } else if (action.equals(ACTION_CALL_HIDE_UI)) {

            HideCallNotification(context, intent);
            HideCallScreen(context, intent);

        } else if (action.equals(ACTION_CALL_CONNECT)) {

            // Hide call UI
            HideCallNotification(context, intent);
            HideCallScreen(context, intent);

            try {
                // get data from intent
                model_callNotification notificationData = new model_callNotification(new JSONObject(intent.getStringExtra("data")));

                // Open link
                Intent linkIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(notificationData.link.link));
                linkIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                context.startActivity(linkIntent);
            } catch (JSONException e) {
                e.printStackTrace();
            }

        } else if (action.equals(ACTION_CALL_IGNORE)) {

            HideCallNotification(context, intent);
            HideCallScreen(context, intent);

            // Do some other stuff maybe

        }
    }

    void ShowCallNotification(Context context, Intent intent) throws JSONException, MalformedURLException, IOException, ExecutionException, InterruptedException {
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);

        String dataJSON = intent.getStringExtra("data");
        model_callNotification callData = new model_callNotification(new JSONObject(dataJSON));

        Intent ringScreenIntent = new Intent(context, LinkRingCallScreen.class);
        ringScreenIntent.putExtra("data", dataJSON);
        ringScreenIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent ringScreenPendingIntent = PendingIntent.getActivity(context, 4564, ringScreenIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        Intent connectCallIntent = new Intent(context, CallBroadcastReceiver.class);
        connectCallIntent.setAction(ACTION_CALL_CONNECT);
        connectCallIntent.putExtra("data", dataJSON);
        PendingIntent connectCallPendingIntent = PendingIntent.getBroadcast(context, 6554, connectCallIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        Intent ignoreCallIntent = new Intent(context, CallBroadcastReceiver.class);
        ignoreCallIntent.setAction(ACTION_CALL_IGNORE);
        ignoreCallIntent.putExtra("data", dataJSON);
        PendingIntent ignoreCallPendingIntent = PendingIntent.getBroadcast(context, 6554, ignoreCallIntent, PendingIntent.FLAG_UPDATE_CURRENT);

        NotificationChannel linkCallChannel = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            linkCallChannel = new NotificationChannel(
                    "LinkCallChannel",
                    "Link Calls",
                    NotificationManager.IMPORTANCE_HIGH
            );
            linkCallChannel.setSound(RingtoneManager.getActualDefaultRingtoneUri(context.getApplicationContext(), RingtoneManager.TYPE_RINGTONE),
                    new AudioAttributes.Builder()
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                            .setLegacyStreamType(AudioManager.STREAM_RING)
                            .setFlags(AudioAttributes.FLAG_AUDIBILITY_ENFORCED)
                            .build());
            linkCallChannel.enableVibration(true);
            linkCallChannel.setVibrationPattern(getVibratePattern(CALL_RING_DURATION_SECONDS));
            notificationManager.createNotificationChannel(linkCallChannel);
        }

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(context, "CHANNEL_XXX")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(callData.group.name + "  •  " + callData.sender.name)
                .setContentText((callData.link.hasName) ? callData.link.name : callData.link.uri.getHost())
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setChannelId("LinkCallChannel")
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setOngoing(true)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setTimeoutAfter(CALL_RING_DURATION_SECONDS * 1000)
                .setSound(RingtoneManager.getActualDefaultRingtoneUri(context.getApplicationContext(), RingtoneManager.TYPE_RINGTONE), AudioManager.STREAM_RING)
                .setVibrate(getVibratePattern(CALL_RING_DURATION_SECONDS))
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .addAction(android.R.drawable.ic_notification_clear_all, getActionButtonText(context, "IGNORE", R.color.reject_btn), ignoreCallPendingIntent)
                .addAction(android.R.drawable.ic_menu_call, getActionButtonText(context, "CONNECT", R.color.connect_btn), connectCallPendingIntent)
                .setFullScreenIntent(ringScreenPendingIntent, true);

        Runnable getPictureAndShowNotification = () -> {
            notificationBuilder.setLargeIcon(Utils.getGroupIcon(context, callData));

            Notification alarmNotification = notificationBuilder.build();
            alarmNotification.flags = Notification.FLAG_INSISTENT;
            notificationManager.notify(CALL_SCREEN_NOTIF_ID, alarmNotification);

        };
        new Thread(getPictureAndShowNotification).start();

        // Set broadcast call after 30sec to cancel this call notification
        Intent callHideIntent = new Intent(context, CallBroadcastReceiver.class);
        callHideIntent.setAction(ACTION_CALL_HIDE_UI);
        callHideIntent.putExtra("data", dataJSON);
        PendingIntent callHidePendingIntent = PendingIntent.getBroadcast(context, 1235, callHideIntent, PendingIntent.FLAG_UPDATE_CURRENT);
        alarmManager.setExact(AlarmManager.RTC, System.currentTimeMillis() + 30000, callHidePendingIntent);

        // Send acknowledgement for call
        sendAcknowledgement(context, callData);
    }

    void HideCallNotification(Context context, Intent intent) {
        NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.cancel(CALL_SCREEN_NOTIF_ID);
    }

    void HideCallScreen(Context context, Intent intent) {
        // This broadcast call for LinkRingScreen for cancelling the inCallUI
        context.getApplicationContext().sendBroadcast(new Intent(ACTION_CALL_HIDE_UI));
    }

    private Spannable getActionButtonText(Context context, String string, @ColorRes int colorRes) {
        Spannable spannable = new SpannableString(string);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            spannable.setSpan(
                    new ForegroundColorSpan(context.getColor(colorRes)), 0, spannable.length(), 0);
        }
        return spannable;
    }

    private long[] getVibratePattern(int seconds) {
        long[] pattern = new long[seconds];
        for (int i = 0; i < seconds; i++) pattern[i] = 1000;
        return pattern;
    }

    void sendAcknowledgement(Context context, model_callNotification callData) throws JSONException {
        // Instantiate the RequestQueue.
        RequestQueue queue = Volley.newRequestQueue(context);
        String url = Constants.ENDPOINT_ACKNOWLEDGEMENT;

        JSONObject requestBody = new JSONObject();
        requestBody.put("linkId", callData.link.id);
        requestBody.put("groupId", callData.group.id);
        requestBody.put("memberId", callData.member.id);

        // Request a string response from the provided URL.
        JsonObjectRequest request = new JsonObjectRequest(Request.Method.POST, url, requestBody, response -> {

        }, error -> {

        }) {
            @Override
            public Map<String, String> getHeaders() throws AuthFailureError {
                Map<String, String> params = new HashMap<String, String>();
                params.put("Content-Type", "application/json; charset=UTF-8");
                params.put("Authorization", "Basic " + Constants.SERVER_KEY);
                return params;
            }
        };

        // Add the request to the RequestQueue.
        queue.add(request);
    }
}
