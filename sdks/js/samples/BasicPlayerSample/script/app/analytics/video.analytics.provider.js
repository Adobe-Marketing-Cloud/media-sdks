/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2014 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */

(function() {
    'use strict';

    var MediaHeartbeat = ADB.va.MediaHeartbeat;
    var MediaHeartbeatConfig = ADB.va.MediaHeartbeatConfig;
    var MediaHeartbeatDelegate = ADB.va.MediaHeartbeatDelegate;

    function VideoAnalyticsProvider(player) {
        if (!player) {
            throw new Error("Illegal argument. Player reference cannot be null.")
        }
        this._player = player;

        // Set-up the Visitor and AppMeasurement instances.
        var visitor = new Visitor(Configuration.VISITOR.MARKETING_CLOUD_ORG_ID);
        visitor.trackingServer = Configuration.VISITOR.TRACKING_SERVER;
        visitor.setCustomerIDs({
            "userId": {
                "id": Configuration.VISITOR.DPID
            },
            "puuid": {
                "id": Configuration.VISITOR.DPUUID
            }
        });

        // Set-up the AppMeasurement component.
        var appMeasurement = new AppMeasurement();
        appMeasurement.visitor = visitor;
        appMeasurement.trackingServer = Configuration.APP_MEASUREMENT.TRACKING_SERVER;
        appMeasurement.account = Configuration.APP_MEASUREMENT.RSID;
        appMeasurement.pageName = Configuration.APP_MEASUREMENT.PAGE_NAME;
        appMeasurement.charSet = "UTF-8";
        appMeasurement.visitorID = "test-vid";

        //Media Heartbeat initialization
        var mediaConfig = new MediaHeartbeatConfig();
        mediaConfig.trackingServer = Configuration.HEARTBEAT.TRACKING_SERVER;
        mediaConfig.playerName = Configuration.PLAYER.NAME;
        mediaConfig.channel = Configuration.HEARTBEAT.CHANNEL;
        mediaConfig.debugLogging = true;
        mediaConfig.appVersion = Configuration.HEARTBEAT.SDK;
        mediaConfig.ssl = false;
        mediaConfig.ovp = Configuration.HEARTBEAT.OVP;

        // Implement the sample MediaHeartbeatDelegate to provide Playhead information and QoS information from the player
        $.extend(SampleMediaHeartbeatDelegate.prototype, MediaHeartbeatDelegate.prototype);

        function SampleMediaHeartbeatDelegate(player) {
            this._player = player;
        }

        SampleMediaHeartbeatDelegate.prototype.getCurrentPlaybackTime = function() {
            return this._player.getCurrentPlaybackTime();
        };

        SampleMediaHeartbeatDelegate.prototype.getQoSObject = function() {
            return this._player.getQoSInfo();
        };
        this._mediaHeartbeat = new MediaHeartbeat(new SampleMediaHeartbeatDelegate(this._player), mediaConfig, appMeasurement);

        this._installEventListeners();
    }

    VideoAnalyticsProvider.prototype.destroy = function() {
        if (this._player) {
            this._mediaHeartbeat = null;
            this._player = null;
            this._uninstallEventListeners();
        }
    };


    /////////
    // Notification handlers
    /////////

    VideoAnalyticsProvider.prototype._onLoad = function() {
        console.log('Player event: VIDEO_LOAD');
        var contextData = {
            isUserLoggedIn: "false",
            tvStation: "Sample TV station",
            programmer: "Sample programmer"
        };

        var videoInfo = this._player.getVideoInfo();
        var mediaInfo = MediaHeartbeat.createMediaObject(videoInfo.name, videoInfo.id, videoInfo.length,videoInfo.streamType);

        //Set to true if this is a resume playback scenario (not starting from playhead 0)
        //mediaInfo.setValue(MediaHeartbeat.MediaObjectKey.VideoResumed, true);

        // Set standard Video Metadata
        var standardVideoMetadata = {};
        standardVideoMetadata[MediaHeartbeat.VideoMetadataKeys.EPISODE] = "Sample Episode";
        standardVideoMetadata[MediaHeartbeat.VideoMetadataKeys.SHOW] = "Sample Show";

        mediaInfo.setValue(MediaHeartbeat.MediaObjectKey.StandardVideoMetadata, standardVideoMetadata);

        this._mediaHeartbeat.trackSessionStart(mediaInfo, contextData);
    };

    VideoAnalyticsProvider.prototype._onUnload = function() {
        console.log('Player event: VIDEO_UNLOAD');
        this._mediaHeartbeat.trackSessionEnd();
    };

    VideoAnalyticsProvider.prototype._onPlay = function() {
        console.log('Player event: PLAY');
        this._mediaHeartbeat.trackPlay();
    };

    VideoAnalyticsProvider.prototype._onPause = function() {
        console.log('Player event: PAUSE');
        this._mediaHeartbeat.trackPause();
    };

    VideoAnalyticsProvider.prototype._onSeekStart = function() {
        console.log('Player event: SEEK_START');
        this._mediaHeartbeat.trackEvent(MediaHeartbeat.Event.SeekStart);
    };

    VideoAnalyticsProvider.prototype._onSeekComplete = function() {
        console.log('Player event: SEEK_COMPLETE');
        this._mediaHeartbeat.trackEvent(MediaHeartbeat.Event.SeekComplete);
    };

    VideoAnalyticsProvider.prototype._onBufferStart = function() {
        console.log('Player event: BUFFER_START');
        this._mediaHeartbeat.trackEvent(MediaHeartbeat.Event.BufferStart);
    };

    VideoAnalyticsProvider.prototype._onBufferComplete = function() {
        console.log('Player event: BUFFER_COMPLETE');
        this._mediaHeartbeat.trackEvent(MediaHeartbeat.Event.BufferComplete);
    };

    VideoAnalyticsProvider.prototype._onAdStart = function() {
        console.log('Player event: AD_START');
        var adContextData = {
            affiliate: "Sample affiliate",
            campaign: "Sample ad campaign"
        };

        // AdBreak Info - getting the adBreakInfo from player and creating AdBreakInfo Object from MediaHeartbeat
        var _adBreakInfo = this._player.getAdBreakInfo();
        var adBreakInfo = MediaHeartbeat.createAdBreakObject(_adBreakInfo.name, _adBreakInfo.position, _adBreakInfo.startTime);

        // Ad Info - getting the adInfo from player and creating AdInfo Object from MediaHeartbeat
        var _adInfo = this._player.getAdInfo();
        var adInfo = MediaHeartbeat.createAdObject(_adInfo.name, _adInfo.id, _adInfo.position, _adInfo.length);

        // Set standard Ad Metadata
        var standardAdMetadata = {};
        standardAdMetadata[MediaHeartbeat.AdMetadataKeys.ADVERTISER] = "Sample Advertiser";
        standardAdMetadata[MediaHeartbeat.AdMetadataKeys.CAMPAIGN_ID] = "Sample Campaign";

        adInfo.setValue(MediaHeartbeat.MediaObjectKey.StandardAdMetadata, standardAdMetadata);

        this._mediaHeartbeat.trackEvent(MediaHeartbeat.Event.AdBreakStart, adBreakInfo);
        this._mediaHeartbeat.trackEvent(MediaHeartbeat.Event.AdStart, adInfo, adContextData);
    };

    VideoAnalyticsProvider.prototype._onAdComplete = function() {
        console.log('Player event: AD_COMPLETE');
        this._mediaHeartbeat.trackEvent(MediaHeartbeat.Event.AdComplete);
        this._mediaHeartbeat.trackEvent(MediaHeartbeat.Event.AdBreakComplete);
    };

    VideoAnalyticsProvider.prototype._onChapterStart = function() {
        console.log('Player event: CHAPTER_START');
        var chapterContextData = {
            segmentType: "Sample segment type"
        };

        // Chapter Info - getting the chapterInfo from player and creating ChapterInfo Object from MediaHeartbeat
        var _chapterInfo = this._player.getChapterInfo();
        var chapterInfo = MediaHeartbeat.createChapterObject(_chapterInfo.name, _chapterInfo.position, _chapterInfo.length, _chapterInfo.startTime);

        this._mediaHeartbeat.trackEvent(MediaHeartbeat.Event.ChapterStart, chapterInfo, chapterContextData);
    };

    VideoAnalyticsProvider.prototype._onChapterComplete = function() {
        console.log('Player event: CHAPTER_COMPLETE');
        this._mediaHeartbeat.trackEvent(MediaHeartbeat.Event.ChapterComplete);
    };

    VideoAnalyticsProvider.prototype._onComplete = function() {
        console.log('Player event: COMPLETE');
        this._mediaHeartbeat.trackComplete();
    };


    /////////
    // Private helper functions
    /////////

    VideoAnalyticsProvider.prototype._installEventListeners = function() {
        // We register as observers to various VideoPlayer events.
        NotificationCenter().addEventListener(PlayerEvent.VIDEO_LOAD, this._onLoad, this);
        NotificationCenter().addEventListener(PlayerEvent.VIDEO_UNLOAD, this._onUnload, this);
        NotificationCenter().addEventListener(PlayerEvent.PLAY, this._onPlay, this);
        NotificationCenter().addEventListener(PlayerEvent.PAUSE, this._onPause, this);
        NotificationCenter().addEventListener(PlayerEvent.SEEK_START, this._onSeekStart, this);
        NotificationCenter().addEventListener(PlayerEvent.SEEK_COMPLETE, this._onSeekComplete, this);
        NotificationCenter().addEventListener(PlayerEvent.BUFFER_START, this._onBufferStart, this);
        NotificationCenter().addEventListener(PlayerEvent.BUFFER_COMPLETE, this._onBufferComplete, this);
        NotificationCenter().addEventListener(PlayerEvent.AD_START, this._onAdStart, this);
        NotificationCenter().addEventListener(PlayerEvent.AD_COMPLETE, this._onAdComplete, this);
        NotificationCenter().addEventListener(PlayerEvent.CHAPTER_START, this._onChapterStart, this);
        NotificationCenter().addEventListener(PlayerEvent.CHAPTER_COMPLETE, this._onChapterComplete, this);
        NotificationCenter().addEventListener(PlayerEvent.COMPLETE, this._onComplete, this);
    };

    VideoAnalyticsProvider.prototype._uninstallEventListeners = function() {
        // We register as observers to various VideoPlayer events.
        NotificationCenter().removeEventListener(PlayerEvent.VIDEO_LOAD, this._onLoad, this);
        NotificationCenter().removeEventListener(PlayerEvent.VIDEO_UNLOAD, this._onUnload, this);
        NotificationCenter().removeEventListener(PlayerEvent.PLAY, this._onPlay, this);
        NotificationCenter().removeEventListener(PlayerEvent.PAUSE, this._onPause, this);
        NotificationCenter().removeEventListener(PlayerEvent.SEEK_START, this._onSeekStart, this);
        NotificationCenter().removeEventListener(PlayerEvent.SEEK_COMPLETE, this._onSeekComplete, this);
        NotificationCenter().removeEventListener(PlayerEvent.BUFFER_START, this._onBufferStart, this);
        NotificationCenter().removeEventListener(PlayerEvent.BUFFER_COMPLETE, this._onBufferComplete, this);
        NotificationCenter().removeEventListener(PlayerEvent.AD_START, this._onAdStart, this);
        NotificationCenter().removeEventListener(PlayerEvent.AD_COMPLETE, this._onAdComplete, this);
        NotificationCenter().removeEventListener(PlayerEvent.CHAPTER_START, this._onChapterStart, this);
        NotificationCenter().removeEventListener(PlayerEvent.CHAPTER_COMPLETE, this._onChapterComplete, this);
        NotificationCenter().removeEventListener(PlayerEvent.COMPLETE, this._onComplete, this);
    };

    // Export symbols.
    window.VideoAnalyticsProvider = VideoAnalyticsProvider;
})();
