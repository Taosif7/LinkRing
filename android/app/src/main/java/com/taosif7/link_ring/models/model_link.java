package com.taosif7.link_ring.models;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.json.JSONObject;

public class model_link {

    public String id, link, name, senderId;
    DateTime sentTime;

    public model_link(JSONObject object) {
        this.id = object.optString("id");
        this.link = object.optString("link");
        this.name = object.optString("name");
        this.senderId = object.optString("sent_by");
        this.sentTime = DateTime.parse(object.optString("sent_time"), DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss.SSSSSSZ"));
    }

}
