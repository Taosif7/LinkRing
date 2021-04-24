package com.taosif7.link_ring;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.media.AudioAttributes;
import android.media.AudioManager;
import android.media.RingtoneManager;
import android.os.Build;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;

import androidx.annotation.ColorRes;
import androidx.core.app.NotificationCompat;

import com.onesignal.OSMutableNotification;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationReceivedEvent;
import com.onesignal.OneSignal.OSRemoteNotificationReceivedHandler;

import static com.taosif7.link_ring.LinkRingCallScreen.CALL_SCREEN_NOTIF_ID;

public class NotificationServiceExtension implements OSRemoteNotificationReceivedHandler {

    @Override
    public void remoteNotificationReceived(Context context, OSNotificationReceivedEvent notificationReceivedEvent) {
        OSNotification notification = notificationReceivedEvent.getNotification();

        // Example of modifying the notification's accent color
        OSMutableNotification mutableNotification = notification.mutableCopy();
        //mutableNotification.setExtender(builder -> builder.setColor(context.getResources().getColor(R.color.cardview_light_background)));

        // TODO: Identify type of notification from data and show call screen
        Intent i = new Intent(context, LinkRingCallScreen.class);
        i.putExtra("data", mutableNotification.getAdditionalData().toString());
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pi = PendingIntent.getActivity(context, 4564, i, PendingIntent.FLAG_UPDATE_CURRENT);
        NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

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
            linkCallChannel.setVibrationPattern(new long[]{1000, 1000, 1000, 1000, 1000, 1000});
            nm.createNotificationChannel(linkCallChannel);
        }

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(context, "CHANNEL_XXX")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("LinkRing Call")
                .setContentText("Incoming call")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setChannelId("LinkCallChannel")
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setOngoing(true)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setTimeoutAfter(30000)
                .setSound(RingtoneManager.getActualDefaultRingtoneUri(context.getApplicationContext(), RingtoneManager.TYPE_RINGTONE), AudioManager.STREAM_RING)
                .setVibrate(new long[]{1000, 1000, 1000, 1000, 1000, 1000})
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .addAction(android.R.drawable.ic_notification_clear_all, getActionButtonText(context, "IGNORE", R.color.reject_btn), pi)
                .addAction(android.R.drawable.ic_menu_call, getActionButtonText(context, "CONNECT", R.color.connect_btn), pi)
                .setFullScreenIntent(pi, true);

        Notification alarmNotification = notificationBuilder.build();

        nm.notify(CALL_SCREEN_NOTIF_ID, alarmNotification);

        // If complete isn't call within a time period of 25 seconds, OneSignal internal logic will show the original notification
        // To omit displaying a notification, pass `null` to complete()
        notificationReceivedEvent.complete(null);
    }

    private Spannable getActionButtonText(Context context, String string, @ColorRes int colorRes) {
        Spannable spannable = new SpannableString(string);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1) {
            spannable.setSpan(
                    new ForegroundColorSpan(context.getColor(colorRes)), 0, spannable.length(), 0);
        }
        return spannable;
    }
}