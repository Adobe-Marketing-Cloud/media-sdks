/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2014 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */

package com.adobe.primetime.va.samples.analytics;

import android.util.Log;

import com.adobe.mobile.Config;
import com.adobe.primetime.va.samples.Configuration;
import com.adobe.primetime.va.samples.player.PlayerEvent;
import com.adobe.primetime.va.samples.player.VideoPlayer;
import com.adobe.primetime.va.simple.MediaHeartbeat;
import com.adobe.primetime.va.simple.MediaHeartbeat.MediaHeartbeatDelegate;
import com.adobe.primetime.va.simple.MediaHeartbeatConfig;
import com.adobe.primetime.va.simple.MediaObject;

import java.util.*;

public class VideoAnalyticsProvider implements Observer, MediaHeartbeatDelegate {
    private static final String LOG_TAG = "[VideoHeartbeatSample]::" + VideoAnalyticsProvider.class.getSimpleName();

    private VideoPlayer _player;
    private MediaHeartbeat _heartbeat;

    public VideoAnalyticsProvider(VideoPlayer player) {
        if (player == null) {
            throw new IllegalArgumentException("Player reference cannot be null.");
        }
        _player = player;
        _player.addObserver(this);

        // Setup the visitor id - optional parameter to be set by the player
        Config.setUserIdentifier("test-vid");

        // Media Heartbeat initialization
        MediaHeartbeatConfig config = new MediaHeartbeatConfig();

        config.trackingServer = Configuration.HEARTBEAT_TRACKING_SERVER;
        config.channel = Configuration.HEARTBEAT_CHANNEL;
        config.appVersion = Configuration.HEARTBEAT_SDK;
        config.ovp = Configuration.HEARTBEAT_OVP;
        config.playerName = Configuration.PLAYER_NAME;
        config.ssl = false;
        config.debugLogging = true;

        _heartbeat = new MediaHeartbeat(this, config);
    }

    @Override
    public MediaObject getQoSObject() {
        // Build a static/hard-coded QoS info here.
        Map<String, Object> qoSInfo = _player.getQoSInfo();
        Long bitrate = (Long) qoSInfo.get("bitrate");
        Double startupTime = (Double) qoSInfo.get("startupTime");
        Double fps = (Double) qoSInfo.get("fps");
        Long droppedFrames = (Long) qoSInfo.get("droppedFrames");
        return MediaHeartbeat.createQoSObject(bitrate, startupTime, fps, droppedFrames);
    }

    @Override
    public Double getCurrentPlaybackTime() {
        return _player.getCurrentPlaybackTime();
    }

    public void destroy() {
        if (_player != null) {
            _heartbeat.trackSessionEnd();
            _heartbeat = null;

            _player.destroy();
            _player.deleteObserver(this);
            _player = null;
        }
    }

    @Override
    public void update(Observable observable, Object data) {
        PlayerEvent playerEvent = (PlayerEvent) data;

        switch (playerEvent) {
            case VIDEO_LOAD:
                Log.d(LOG_TAG, "Video loaded.");
                HashMap<String, String> videoMetadata = new HashMap<String, String>();
                videoMetadata.put("isUserLoggedIn", "false");
                videoMetadata.put("tvStation", "Sample TV Station");
                videoMetadata.put("programmer", "Sample programmer");

                MediaObject mediaInfo = MediaHeartbeat.createMediaObject(
                        Configuration.VIDEO_NAME,
                        Configuration.VIDEO_ID,
                        Configuration.VIDEO_LENGTH,
                        MediaHeartbeat.StreamType.VOD
                );

                // Set standard Video Metadata
                Map <String, String> standardVideoMetadata= new HashMap<String, String>();
                standardVideoMetadata.put(MediaHeartbeat.VideoMetadataKeys.EPISODE, "Sample Episode");
                standardVideoMetadata.put(MediaHeartbeat.VideoMetadataKeys.SHOW, "Sample Show");

                mediaInfo.setValue(MediaHeartbeat.MediaObjectKey.StandardVideoMetadata, standardVideoMetadata);

                //Set to true if this is a resume playback scenario (not starting from playhead 0)
//                mediaInfo.setValue(MediaHeartbeat.MediaObjectKey.VideoResumed, true);

                _heartbeat.trackSessionStart(mediaInfo, videoMetadata);
                break;

            case VIDEO_UNLOAD:
                Log.d(LOG_TAG, "Video unloaded.");
                _heartbeat.trackSessionEnd();
                break;

            case PLAY:
                Log.d(LOG_TAG, "Playback started.");
                _heartbeat.trackPlay();
                break;

            case PAUSE:
                Log.d(LOG_TAG, "Playback paused.");
                _heartbeat.trackPause();
                break;

            case SEEK_START:
                Log.d(LOG_TAG, "Seek started.");
                _heartbeat.trackEvent(MediaHeartbeat.Event.SeekStart, null, null);
                break;

            case SEEK_COMPLETE:
                Log.d(LOG_TAG, "Seek completed.");
                _heartbeat.trackEvent(MediaHeartbeat.Event.SeekComplete, null, null);
                break;

            case BUFFER_START:
                Log.d(LOG_TAG, "Buffer started.");
                _heartbeat.trackEvent(MediaHeartbeat.Event.BufferStart, null, null);
                break;

            case BUFFER_COMPLETE:
                Log.d(LOG_TAG, "Buffer completed.");
                _heartbeat.trackEvent(MediaHeartbeat.Event.BufferComplete, null, null);
                break;

            case AD_START:
                Log.d(LOG_TAG, "Ad started.");
                HashMap<String, String> adMetadata = new HashMap<String, String>();
                adMetadata.put("affiliate", "Sample affiliate");
                adMetadata.put("campaign", "Sample ad campaign");

                // Ad Break Info
                Map<String, Object> adBreakData = _player.getAdBreakInfo();
                String name = (String) adBreakData.get("name");
                Long position = (Long) adBreakData.get("position");
                Double startTime = (Double) adBreakData.get("startTime");

                MediaObject adBreakInfo = MediaHeartbeat.createAdBreakObject(name, position, startTime);

                // Ad Info
                Map<String, Object> adData = _player.getAdInfo();
                String adName = (String) adData.get("name");
                String adId = (String) adData.get("id");
                Long adPosition = (Long) adData.get("position");
                Double adLength = (Double) adData.get("length");

                MediaObject adInfo = MediaHeartbeat.createAdObject(adName, adId, adPosition, adLength);

                // Setting standard Ad Metadata
                Map <String, String> standardAdMetadata= new HashMap<String, String>();
                standardAdMetadata.put(MediaHeartbeat.AdMetadataKeys.ADVERTISER, "Sample Advertiser");
                standardAdMetadata.put(MediaHeartbeat.AdMetadataKeys.CAMPAIGN_ID, "Sample Campaign");

                adInfo.setValue(MediaHeartbeat.MediaObjectKey.StandardAdMetadata, standardAdMetadata);

                _heartbeat.trackEvent(MediaHeartbeat.Event.AdBreakStart, adBreakInfo, null);
                _heartbeat.trackEvent(MediaHeartbeat.Event.AdStart, adInfo, adMetadata);
                break;

            case AD_COMPLETE:
                Log.d(LOG_TAG, "Ad completed.");
                _heartbeat.trackEvent(MediaHeartbeat.Event.AdComplete, null, null);
                _heartbeat.trackEvent(MediaHeartbeat.Event.AdBreakComplete, null, null);
                break;

            case CHAPTER_START:
                Log.d(LOG_TAG, "Chapter started.");
                HashMap<String, String> chapterMetadata = new HashMap<String, String>();
                chapterMetadata.put("segmentType", "Sample Segment Type");

                // Chapter Info
                Map<String, Object> chapterData = _player.getChapterInfo();
                String chapterName = (String) chapterData.get("name");
                Long chapterPosition = (Long) chapterData.get("position");
                Double chapterLength = (Double) chapterData.get("length");
                Double chapterStartTime = (Double) chapterData.get("startTime");

                MediaObject chapterDataInfo = MediaHeartbeat.createChapterObject(chapterName, chapterPosition, chapterLength, chapterStartTime);

                _heartbeat.trackEvent(MediaHeartbeat.Event.ChapterStart, chapterDataInfo, chapterMetadata);
                break;

            case CHAPTER_COMPLETE:
                Log.d(LOG_TAG, "Chapter completed.");
                _heartbeat.trackEvent(MediaHeartbeat.Event.ChapterComplete, null, null);
                break;

            case COMPLETE:
                Log.d(LOG_TAG, "Playback completed.");

                _heartbeat.trackComplete();
                break;

            default:
                Log.d(LOG_TAG, "Unhandled player event: " + playerEvent.toString());
                break;
        }
    }
}
