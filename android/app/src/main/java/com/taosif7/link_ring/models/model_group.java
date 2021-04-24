package com.taosif7.link_ring.models;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.json.JSONObject;

public class model_group {

    public String id, name, iconUrl;
    public boolean autoJoin;
    public DateTime creationTime;

    public model_group(JSONObject object) {
        this.id = object.optString("id");
        this.name = object.optString("name");
        this.iconUrl = object.optString("icon_url");
        this.autoJoin = object.optBoolean("auto_join");
        this.creationTime = DateTime.parse(object.optString("creation_time"), DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss.SSSSSSZ"));
    }

}
