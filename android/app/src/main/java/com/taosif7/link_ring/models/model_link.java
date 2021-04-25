package com.taosif7.link_ring.models;

import android.net.Uri;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.json.JSONObject;

public class model_link {

    public String id, link, name, senderId;
    public DateTime sentTime;
    public Uri uri;
    public boolean hasName;

    public model_link(JSONObject object) {
        this.id = object.optString("id");
        this.link = object.optString("link");
        this.name = object.optString("name");
        this.senderId = object.optString("sent_by");
        this.sentTime = DateTime.parse(object.optString("sent_time"), DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss.SSSSSSZ"));
        this.uri = Uri.parse(this.link);
        this.hasName = this.name.length() > 0 && !this.name.equals("null");
    }

}
