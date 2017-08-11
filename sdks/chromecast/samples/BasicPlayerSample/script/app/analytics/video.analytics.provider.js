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

    function VideoAnalyticsProvider(player) {

        if (!player) {
            throw new Error("Illegal argument. Player reference cannot be null.")
        }

        this._player = player;

        // Sample to set the privacy status
        //ADBMobile.config.setPrivacyStatus(ADBMobile.config.PRIVACY_STATUS_OPT_IN);

        //Enable logging
        ADBMobile.config.setDebugLogging(true);

        //If needed, set Custom User unique identifier
        //ADBMobile.config.setUserIdentifier("test-UserId");

        //Set media delegate
        ADBMobile.media.setDelegate(this);

        this._installEventListeners();
    }

    VideoAnalyticsProvider.prototype.destroy = function() {
        if (this._player) {
           // Remove delegate reference
            ADBMobile.media.setDelegate(null);

            this._uninstallEventListeners();            
        }
    };

    /////////
    // VHL media delegate
    /////////

    VideoAnalyticsProvider.prototype.getCurrentPlaybackTime = function() {
        return this._player.getCurrentPlaybackTime();
    };

    VideoAnalyticsProvider.prototype.getQoSObject = function() {
        return this._player.getQoSInfo();
    };

    /////////
    // Notification handlers
    /////////

    VideoAnalyticsProvider.prototype._onLoad = function() {

        console.log('Player event: VIDEO_LOAD');

        var VideoMetadataKeys = ADBMobile.media.VideoMetadataKeys;

        var mediaMetadata = {
            isUserLoggedIn: "false",
            tvStation: "Sample TV station",
            programmer: "Sample programmer"
        };

        var mediaObject = this._player.getVideoInfo();

        var standardVideoMetadata = {};
        standardVideoMetadata[VideoMetadataKeys.SHOW] = "Sample show";
        standardVideoMetadata[VideoMetadataKeys.SEASON] = "Sample season";

        mediaObject[ADBMobile.media.MediaObjectKey.StandardVideoMetadata] = standardVideoMetadata;

        //Set to true if this video session is a resumed session
        //mediaObject[ADBMobile.media.MediaObjectKey.VideoResumed] = true;

        ADBMobile.media.trackSessionStart(mediaObject, mediaMetadata);
    };

    VideoAnalyticsProvider.prototype._onUnload = function() {
        console.log('Player event: VIDEO_UNLOAD');
        ADBMobile.media.trackSessionEnd();
    };

    VideoAnalyticsProvider.prototype._onPlay = function() {
        console.log('Player event: PLAY');
        ADBMobile.media.trackPlay();
    };

    VideoAnalyticsProvider.prototype._onUpdate = function() {
        console.log('Player event: PLAYHEAD UPDATE');
    };

    VideoAnalyticsProvider.prototype._onPause = function() {
        console.log('Player event: PAUSE');
        ADBMobile.media.trackPause();
    };

    VideoAnalyticsProvider.prototype._onSeekStart = function() {
        console.log('Player event: SEEK_START');
        ADBMobile.media.trackEvent(ADBMobile.media.Event.SeekStart);
    };

    VideoAnalyticsProvider.prototype._onSeekComplete = function() {
        console.log('Player event: SEEK_COMPLETE');
        ADBMobile.media.trackEvent(ADBMobile.media.Event.SeekComplete);
    };

    VideoAnalyticsProvider.prototype._onBufferStart = function() {
        console.log('Player event: BUFFER_START');
        ADBMobile.media.trackEvent(ADBMobile.media.Event.BufferStart);
    };

    VideoAnalyticsProvider.prototype._onBufferComplete = function() {
        console.log('Player event: BUFFER_COMPLETE');
        ADBMobile.media.trackEvent(ADBMobile.media.Event.BufferComplete);
    };

    VideoAnalyticsProvider.prototype._onAdStart = function() {
        console.log('Player event: AD_START');

        var adContextData = {
            affiliate: "Sample affiliate",
            campaign: "Sample ad campaign"
        };

        ADBMobile.media.trackEvent(ADBMobile.media.Event.AdStart, this._player.getAdInfo(), adContextData);
    };

    VideoAnalyticsProvider.prototype._onAdComplete = function() {
        console.log('Player event: AD_BREAK_COMPLETE');
        ADBMobile.media.trackEvent(ADBMobile.media.Event.AdComplete);
    };

    VideoAnalyticsProvider.prototype._onAdBreakStart = function() {
        console.log('Player event: AD_BREAK_START');
        ADBMobile.media.trackEvent(ADBMobile.media.Event.AdBreakStart, this._player.getAdBreakInfo());
    };

    VideoAnalyticsProvider.prototype._onAdBreakComplete = function() {
        console.log('Player event: AD_BREAK_START');
        ADBMobile.media.trackEvent(ADBMobile.media.Event.AdBreakComplete);
    };

    VideoAnalyticsProvider.prototype._onChapterStart = function() {
        console.log('Player event: CHAPTER_START');
        var chapterContextData = {
            segmentType: "Sample segment type"
        };
        ADBMobile.media.trackEvent(ADBMobile.media.Event.ChapterStart, this._player.getChapterInfo(), chapterContextData);
    };

    VideoAnalyticsProvider.prototype._onChapterComplete = function() {
        console.log('Player event: CHAPTER_COMPLETE');
        ADBMobile.media.trackEvent(ADBMobile.media.Event.ChapterComplete);
    };

    VideoAnalyticsProvider.prototype._onComplete = function() {
        console.log('Player event: COMPLETE');
        ADBMobile.media.trackComplete();
    };


    /////////
    // Private helper functions
    /////////

    VideoAnalyticsProvider.prototype._installEventListeners = function() {
        // We register as observers to various VideoPlayer events.
        NotificationCenter().addEventListener(PlayerEvent.VIDEO_LOAD, this._onLoad, this);
        NotificationCenter().addEventListener(PlayerEvent.VIDEO_UNLOAD, this._onUnload, this);
        NotificationCenter().addEventListener(PlayerEvent.PLAY, this._onPlay, this);
        NotificationCenter().addEventListener(PlayerEvent.PLAYHEAD_UPDATE, this._onUpdate, this);
        NotificationCenter().addEventListener(PlayerEvent.PAUSE, this._onPause, this);
        NotificationCenter().addEventListener(PlayerEvent.SEEK_START, this._onSeekStart, this);
        NotificationCenter().addEventListener(PlayerEvent.SEEK_COMPLETE, this._onSeekComplete, this);
        NotificationCenter().addEventListener(PlayerEvent.BUFFER_START, this._onBufferStart, this);
        NotificationCenter().addEventListener(PlayerEvent.BUFFER_COMPLETE, this._onBufferComplete, this);
        NotificationCenter().addEventListener(PlayerEvent.AD_START, this._onAdStart, this);
        NotificationCenter().addEventListener(PlayerEvent.AD_COMPLETE, this._onAdComplete, this);
        NotificationCenter().addEventListener(PlayerEvent.AD_BREAK_START, this._onAdBreakStart, this);
        NotificationCenter().addEventListener(PlayerEvent.AD_BREAK_COMPLETE, this._onAdBreakComplete, this);
        NotificationCenter().addEventListener(PlayerEvent.CHAPTER_START, this._onChapterStart, this);
        NotificationCenter().addEventListener(PlayerEvent.CHAPTER_COMPLETE, this._onChapterComplete, this);
        NotificationCenter().addEventListener(PlayerEvent.COMPLETE, this._onComplete, this);
    };

    VideoAnalyticsProvider.prototype._uninstallEventListeners = function() {
        // We register as observers to various VideoPlayer events.
        NotificationCenter().removeEventListener(PlayerEvent.VIDEO_LOAD, this._onLoad, this);
        NotificationCenter().removeEventListener(PlayerEvent.VIDEO_UNLOAD, this._onUnload, this);
        NotificationCenter().removeEventListener(PlayerEvent.PLAY, this._onPlay, this);
        NotificationCenter().removeEventListener(PlayerEvent.PLAYHEAD_UPDATE, this._onUpdate, this);
        NotificationCenter().removeEventListener(PlayerEvent.PAUSE, this._onPause, this);
        NotificationCenter().removeEventListener(PlayerEvent.SEEK_START, this._onSeekStart, this);
        NotificationCenter().removeEventListener(PlayerEvent.SEEK_COMPLETE, this._onSeekComplete, this);
        NotificationCenter().removeEventListener(PlayerEvent.BUFFER_START, this._onBufferStart, this);
        NotificationCenter().removeEventListener(PlayerEvent.BUFFER_COMPLETE, this._onBufferComplete, this);
        NotificationCenter().removeEventListener(PlayerEvent.AD_START, this._onAdStart, this);
        NotificationCenter().removeEventListener(PlayerEvent.AD_COMPLETE, this._onAdComplete, this);
        NotificationCenter().removeEventListener(PlayerEvent.AD_BREAK_START, this._onAdBreakStart, this);
        NotificationCenter().removeEventListener(PlayerEvent.AD_BREAK_COMPLETE, this._onAdBreakComplete, this);
        NotificationCenter().removeEventListener(PlayerEvent.CHAPTER_START, this._onChapterStart, this);
        NotificationCenter().removeEventListener(PlayerEvent.CHAPTER_COMPLETE, this._onChapterComplete, this);
        NotificationCenter().removeEventListener(PlayerEvent.COMPLETE, this._onComplete, this);
    };

    // Export symbols.
    window.VideoAnalyticsProvider = VideoAnalyticsProvider;
})();
