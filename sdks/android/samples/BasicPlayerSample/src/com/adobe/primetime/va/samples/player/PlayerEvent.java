/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2014 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */

package com.adobe.primetime.va.samples.player;

public enum PlayerEvent {
    VIDEO_LOAD("video_load"),
    VIDEO_UNLOAD("video_unload"),
    PLAY("play"),
    PAUSE("pause"),
    SEEK_START("seek_start"),
    SEEK_COMPLETE("seek_complete"),
    BUFFER_START("buffer_start"),
    BUFFER_COMPLETE("buffer_complete"),
    AD_START("ad_start"),
    AD_COMPLETE("ad_complete"),
    CHAPTER_START("chapter_start"),
    CHAPTER_COMPLETE("chapter_complete"),
    COMPLETE("COMPLETE");

    private final String _type;

    PlayerEvent(String type) {
        _type = type;
    }

    public String getType() { return _type; }
}
