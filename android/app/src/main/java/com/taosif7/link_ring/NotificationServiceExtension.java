package com.taosif7.link_ring;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

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

        Log.d("TAG", "remoteNotificationReceived: Received");

        // TODO: Identify type of notification from data and show call screen
        Intent i = new Intent(context, LinkRingCallScreen.class);
        i.putExtra("data", mutableNotification.getAdditionalData().toString());
        i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        PendingIntent pi = PendingIntent.getActivity(context, 4564, i, PendingIntent.FLAG_UPDATE_CURRENT);
        NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);

        NotificationChannel stopServiceChannel = null;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            stopServiceChannel = new NotificationChannel(
                    "CHANNEL_XXX",
                    "Location Alert Channel",
                    NotificationManager.IMPORTANCE_HIGH
            );
            nm.createNotificationChannel(stopServiceChannel);
        }

        NotificationCompat.Builder notificationBuilder = new NotificationCompat.Builder(context, "CHANNEL_XXX")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle("Link ring call")
                .setContentText("Incoming call")
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setFullScreenIntent(pi, true);

        Notification alarmNotification = notificationBuilder.build();

        nm.notify(CALL_SCREEN_NOTIF_ID, alarmNotification);

        // If complete isn't call within a time period of 25 seconds, OneSignal internal logic will show the original notification
        // To omit displaying a notification, pass `null` to complete()
        notificationReceivedEvent.complete(null);
    }
}