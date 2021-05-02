package com.taosif7.link_ring.models;

import android.graphics.Color;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.json.JSONObject;

public class model_group {

    public String id, name, iconUrl;
    public boolean autoJoin;
    public DateTime creationTime;
    public int startColor, endColor;
    public String initials;

    public model_group(JSONObject object) {
        this.id = object.optString("id");
        this.name = object.optString("name");
        this.iconUrl = object.optString("icon_url");
        this.autoJoin = object.optBoolean("auto_join");
        this.creationTime = DateTime.parse(object.optString("creation_time"), DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss.SSSSSSZ"));
        this.initials = object.optString("initials");
        this.startColor = Color.parseColor(String.format("#%06X", (0xFFFFFF & object.optInt("start_color", 0))));
        this.endColor = Color.parseColor(String.format("#%06X", (0xFFFFFF & object.optInt("end_color", 0))));
    }

}
