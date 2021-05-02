package com.taosif7.link_ring.models;

import org.json.JSONException;
import org.json.JSONObject;

public class model_callNotification {

    public model_link link;
    public model_group group;
    public model_member sender;
    public model_member member;

    public model_callNotification(JSONObject data) {
        try {
            this.member = new model_member(data.getJSONObject("member"));
            this.link = new model_link(data.getJSONObject("link"));
            this.group = new model_group(data.getJSONObject("group"));
            this.sender = new model_member(data.getJSONObject("sender"));
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

}
