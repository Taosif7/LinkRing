package com.taosif7.link_ring.models;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.json.JSONObject;

public class model_member {

    public String id, email, name, profilePicUrl;
    boolean isJoined;
    DateTime joinedOn;

    public model_member(JSONObject object) {
        this.id = object.optString("id");
        this.email = object.optString("email");
        this.name = object.optString("name");
        this.profilePicUrl = object.optString("profilePicUrl");
        this.isJoined = object.optBoolean("is_joined");
        this.joinedOn = DateTime.parse(object.optString("joined_on"), DateTimeFormat.forPattern("yyyy-MM-dd HH:mm:ss.SSSSSSZ"));
    }

}
