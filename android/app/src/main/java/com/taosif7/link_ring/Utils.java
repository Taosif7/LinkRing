package com.taosif7.link_ring;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.Shader;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.FutureTarget;
import com.taosif7.link_ring.models.model_callNotification;

import java.util.concurrent.ExecutionException;

public class Utils {

    public static Bitmap getGroupIcon(Context context, model_callNotification callData) {
        FutureTarget<Bitmap> futureTarget = Glide.with(context)
                .asBitmap()
                .load(callData.group.iconUrl)
                .circleCrop()
                .submit();
        Bitmap groupIcon = null;
        try {
            groupIcon = futureTarget.get();
        } catch (ExecutionException | InterruptedException e) {
            groupIcon = Utils.generateGroupIcon(context, callData);
            e.printStackTrace();
        }

        return groupIcon;
    }

    public static Bitmap generateGroupIcon(Context context, model_callNotification callData) {

        Paint textPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        textPaint.setColor(Color.WHITE);
        textPaint.setTextSize(70);
        textPaint.setFakeBoldText(true);

        Paint circlePaint = new Paint();
        circlePaint.setColor(0xff0088cc);

        int w = 150;  // Width of profile picture
        int h = 150;  // Height of profile picture

        // Draw gradient
        Shader shader = new LinearGradient(0, 0, w, h, callData.group.startColor, callData.group.endColor, Shader.TileMode.CLAMP);
        circlePaint.setShader(shader);
        Bitmap bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        canvas.drawCircle(w / 2, h / 2, w / 2, circlePaint);

        String label = callData.group.initials.toUpperCase();
        Rect labelBounds = new Rect();
        textPaint.getTextBounds(label, 0, label.length(), labelBounds);

        canvas.drawText(label, ((w - labelBounds.width()) / 2f) - 5, 100, textPaint);

        return bitmap;
    }
}
