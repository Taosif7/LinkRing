package com.taosif7.link_ring;

import android.content.Context;
import android.content.Intent;

import com.onesignal.OSMutableNotification;
import com.onesignal.OSNotification;
import com.onesignal.OSNotificationReceivedEvent;
import com.onesignal.OneSignal.OSRemoteNotificationReceivedHandler;

public class NotificationServiceExtension implements OSRemoteNotificationReceivedHandler {

    @Override
    public void remoteNotificationReceived(Context context, OSNotificationReceivedEvent notificationReceivedEvent) {
        OSNotification notification = notificationReceivedEvent.getNotification();

        // Example of modifying the notification's accent color
        OSMutableNotification mutableNotification = notification.mutableCopy();
        //mutableNotification.setExtender(builder -> builder.setColor(context.getResources().getColor(R.color.cardview_light_background)));

        // TODO: Identify type of notification from data and show call screen
        Intent callBroadcast = new Intent(context, CallBroadcastReceiver.class);
        callBroadcast.setAction(CallBroadcastReceiver.ACTION_CALL_SHOW_UI);
        callBroadcast.putExtra("data", mutableNotification.getAdditionalData().toString());
        context.sendBroadcast(callBroadcast);

        // If complete isn't call within a time period of 25 seconds, OneSignal internal logic will show the original notification
        // To omit displaying a notification, pass `null` to complete()
        notificationReceivedEvent.complete(null);
    }
}