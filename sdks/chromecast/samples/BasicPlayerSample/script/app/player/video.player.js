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

    var PlayerEvent = {
        VIDEO_LOAD: 'video_load',
        VIDEO_UNLOAD: 'video_unload',
        PLAY: 'play',
        PLAYHEAD_UPDATE: 'update',
        PAUSE: 'pause',
        COMPLETE: 'COMPLETE',
        BUFFER_START: 'buffer_start',
        BUFFER_COMPLETE: 'buffer_complete',
        SEEK_START: 'seek_start',
        SEEK_COMPLETE: 'seek_complete',
        AD_START: "ad_start",
        AD_COMPLETE: "ad_complete",
        AD_BREAK_START: "ad_break_start",
        AD_BREAK_COMPLETE: "ad_break_complete",
        CHAPTER_START: "chapter_start",
        CHAPTER_COMPLETE: "chapter_complete"
    };

    // This sample VideoPlayer simulates a mid-roll ad at time 15:
    var AD_START_POS = 15;
    var AD_END_POS = 30;
    var AD_LENGTH = 15;

    var CHAPTER1_START_POS = 0;
    var CHAPTER1_END_POS = 15;
    var CHAPTER1_LENGTH = 15;

    var CHAPTER2_START_POS = 30;
    var CHAPTER2_LENGTH = 30;

    var MONITOR_TIMER_INTERVAL = 500;

    function VideoPlayer(castplayer) {
        this._playerName = "Chromecast Custom Cast Player";

        this._videoId = "clickbaby";
        this._videoName = "sample video click-baby";
        this._streamType = ADBMobile.media.StreamType.VOD;
        this._mediaType = ADBMobile.media.MediaType.Video;

        this._videoLoaded = false;

        this._videoInfo = null;
        this._adBreakInfo = null;
        this._adInfo = null;
        this._chapterInfo = null;

        // Build a static/hard-coded QoS info here.
        this._qosInfo = ADBMobile.media.createQoSObject(50000, 0, 24, 10);
        this._clock = null;

        this._castplayer = castplayer;
        this._state = "created";
        this._isPaused = true;
        this._reachedEnd = false;
        
        this._setupEventListeners();
    }

    VideoPlayer.prototype._setupEventListeners = function(){
        var self = this;

        //Use the setState function in CastPlayer to identify the current state of the playback
        this._castplayer.setState_ = function(state, opt_crossfade, opt_delay){

            //Call the prototype setState
            sampleplayer.CastPlayer.prototype.setState_.call(self._castplayer, state, opt_crossfade, opt_delay);

            //When the state is set (After delay/transitions).
            if(!opt_crossfade && !opt_delay && state){
                if(state === sampleplayer.State.LOADING){

                }
                else if(state === sampleplayer.State.BUFFERING)
                {
                    if(self._state != "buffering"){
                        self._onBufferStart();
                        self._state = "buffering";
                    }
                }
                else if(state === sampleplayer.State.PLAYING)
                {
                    if(self._state == "buffering"){
                        self._onBufferComplete();
                    }else if(self._state != "playing"){
                        self._onPlay();
                    }

                    self._state = "playing";
                    self._isPaused = false;
                }
                else if(state === sampleplayer.State.PAUSED)
                {
                    if(self._state != "paused")
                    {
                        self._onPause();
                        self._state = "paused";
                        self._isPaused = true;
                    }
                }
                else if(state === sampleplayer.State.DONE)
                {
                    if(self._state != "completed")
                    {
                        self._onComplete();
                        self._state = "completed";
                    }
                }
                else if(state === sampleplayer.State.IDLE)
                {
                    //Either the player is ready, in error state, or the App went idle
                    if(self._state == "created")
                    {
                        //Player is ready
                        self._state = "ready";
                    }
                    //1 Second of offset. If the current playhead is close to the end we consider this scenario as completed
                    else if(self._reachedEnd)
                    {
                        self._onComplete();
                        self._state = "completed";
                    }
                    else
                    {
                        //Player is in error state or went idle (pause tracking for now)
                        self._onPause();
                        self._state = "paused";
                        self._isPaused = true;
                    }
                }
            }
        };

        this._castplayer.onSeekStart_ = function(){

            //Call the prototype setState
            sampleplayer.CastPlayer.prototype.onSeekStart_.call(self._castplayer);

            if(self._state != "seeking"){
                self._onSeekStart();
                self._state = "seeking";
            }
        };

        this._castplayer.onSeekEnd_ = function(){

            //Call the prototype setState
            sampleplayer.CastPlayer.prototype.onSeekEnd_.call(self._castplayer);

            if(self._state == "seeking"){
                self._onSeekComplete();
                self._state = self._isPaused ? "paused" : "playing";
            }
        };
    };

    VideoPlayer.prototype.getVideoInfo = function() {
        if (this._adInfo) { // During ad playback the main video playhead remains
           // constant at where it was when the ad started
           this._videoInfo.playhead = AD_START_POS;
        } else {
           var vTime = this.getPlayhead();
           this._videoInfo.playhead = (vTime < AD_START_POS) ? vTime : vTime - AD_LENGTH;
        }

        return this._videoInfo;
    };

    VideoPlayer.prototype.getAdBreakInfo = function() {
        return this._adBreakInfo;
    };

    VideoPlayer.prototype.getAdInfo = function() {
        return this._adInfo;
    };

    VideoPlayer.prototype.getChapterInfo = function() {
        return this._chapterInfo;
    };

    VideoPlayer.prototype.getQoSInfo = function() {
        return this._qosInfo;
    };

    VideoPlayer.prototype.getDuration = function() {
        return this._castplayer.mediaElement_.duration - AD_LENGTH;;
    };

    VideoPlayer.prototype.getPlayhead = function() {
        return this._castplayer.mediaElement_.currentTime;
    };

     VideoPlayer.prototype.getCurrentPlaybackTime = function() {
        var vTime = this.getPlayhead();
        var time;
        if(vTime < AD_START_POS){
            time = vTime;
        }
        else if(vTime >= AD_START_POS && vTime < AD_END_POS){
            time =  AD_START_POS;
        }
        else {
            time = vTime - AD_LENGTH; 
        }

        return time;
    };

    VideoPlayer.prototype._onPlay = function(e) {
        this._openVideoIfNecessary();
        NotificationCenter().dispatchEvent(PlayerEvent.PLAY);
    };

    VideoPlayer.prototype._onPause = function(e) {
        NotificationCenter().dispatchEvent(PlayerEvent.PAUSE);
    };

    VideoPlayer.prototype._onSeekStart = function(e) {
        this._openVideoIfNecessary();
        NotificationCenter().dispatchEvent(PlayerEvent.SEEK_START);
    };

    VideoPlayer.prototype._onSeekComplete = function(e) {
        this._doPostSeekComputations();
        NotificationCenter().dispatchEvent(PlayerEvent.SEEK_COMPLETE);
    };

    VideoPlayer.prototype._onBufferStart = function(e) {
        this._openVideoIfNecessary();
        NotificationCenter().dispatchEvent(PlayerEvent.BUFFER_START);
    };

    VideoPlayer.prototype._onBufferComplete = function(e) {
        this._doPostSeekComputations();
        NotificationCenter().dispatchEvent(PlayerEvent.BUFFER_COMPLETE);
    };

    VideoPlayer.prototype._onComplete = function(e) {
        this._completeVideo();
    };

    VideoPlayer.prototype._openVideoIfNecessary = function() {
        if (!this._videoLoaded) {
            this._resetInternalState();
            this._startVideo();

            //Start the monitor timer.
            var self = this;
            this._clock = setInterval(function() {
                self._onTick();
            }, MONITOR_TIMER_INTERVAL);
        }
    };

    VideoPlayer.prototype._completeVideo = function() {
        if (this._videoLoaded) {
            // Complete the second chapter
            this._completeChapter();

            NotificationCenter().dispatchEvent(PlayerEvent.COMPLETE);

            this._unloadVideo();
        }
    };

    VideoPlayer.prototype._unloadVideo = function() {
        NotificationCenter().dispatchEvent(PlayerEvent.VIDEO_UNLOAD);
        clearInterval(this._clock);

        this._resetInternalState();
    };

    VideoPlayer.prototype._resetInternalState = function() {
        this._videoLoaded = false;
        this._clock = null;

        this._videoInfo = null;
        this._adBreakInfo = null;
        this._adInfo = null;
        this._chapterInfo = null;

        this._state = "created";
        this._isPaused = true;
        this._reachedEnd = false;
    };

    VideoPlayer.prototype._startVideo = function() {

        var media = this._castplayer.mediaManager_.getMediaInformation();        

        // Prepare the main video info.
        var id = media.metadata.title ? media.metadata.title : "Undefined video id";
        var name = media.metadata.title ? media.metadata.title : "Undefined video name";
        this._videoInfo = ADBMobile.media.createMediaObject(name, id, this.getDuration(), this._streamType, this._mediaType);
        this._videoLoaded = true;

        NotificationCenter().dispatchEvent(PlayerEvent.VIDEO_LOAD);
    };

    VideoPlayer.prototype._startChapter1 = function() {
        // Prepare the chapter info.
        this._chapterInfo = ADBMobile.media.createChapterObject("First Chapter", 1, CHAPTER1_LENGTH, CHAPTER1_START_POS);        
        NotificationCenter().dispatchEvent(PlayerEvent.CHAPTER_START);
    };

    VideoPlayer.prototype._startChapter2 = function() {
        // Prepare the chapter info.
        this._chapterInfo = ADBMobile.media.createChapterObject("Second Chapter", 2, CHAPTER2_LENGTH, CHAPTER2_START_POS);        
        NotificationCenter().dispatchEvent(PlayerEvent.CHAPTER_START);
    };

    VideoPlayer.prototype._completeChapter = function() {
        // Reset the chapter info.
        this._chapterInfo = null;

        NotificationCenter().dispatchEvent(PlayerEvent.CHAPTER_COMPLETE);
    };

    VideoPlayer.prototype._startAd = function() {
        // Prepare the ad break info.
        this._adBreakInfo = ADBMobile.media.createAdBreakObject("First Ad-Break", 1, AD_START_POS, this._playerName);
        // Prepare the ad info.        
        this._adInfo = ADBMobile.media.createAdObject("Sample ad", "001", 1, AD_LENGTH);

        // Start the ad break.
        NotificationCenter().dispatchEvent(PlayerEvent.AD_BREAK_START);
        NotificationCenter().dispatchEvent(PlayerEvent.AD_START);
    };

    VideoPlayer.prototype._completeAd = function() {
        // Complete the ad.
        NotificationCenter().dispatchEvent(PlayerEvent.AD_COMPLETE);
        NotificationCenter().dispatchEvent(PlayerEvent.AD_BREAK_COMPLETE);

        // Clear the ad and ad-break info.
        this._adInfo = null;
        this._adBreakInfo = null;
    };

    VideoPlayer.prototype._doPostSeekComputations = function() {
        var vTime = this.getPlayhead();

        // Seek inside the first chapter.
        if (vTime < CHAPTER1_START_POS) {
            // If we were not inside the first chapter before, trigger a chapter start
            if (!this._chapterInfo || this._chapterInfo.position != 1) {
                this._startChapter1();

                // If we were in the ad, clear the ad and ad-break info, but don't send the AD_COMPLETE event.
                if (this._adInfo) {
                    this._adInfo = null;
                    this._adBreakInfo = null;
                }
            }
        }

        // Seek inside the ad.
        else if (vTime >= AD_START_POS && vTime < AD_END_POS) {
            // If we were not inside the ad before, trigger an ad-start
            if (!this._adInfo) {
                this._startAd();

                // Also, clear the chapter info, without sending the CHAPTER_COMPLETE event.
                this._chapterInfo = null;
            }
        }

        // Seek inside the second chapter.
        else {
            // If we were not inside the 2nd chapter before, trigger a chapter start
            if (!this._chapterInfo || this._chapterInfo.position != 2) {
                this._startChapter2();

                // If we were in the ad, clear the ad and ad-break info, but don't send the AD_COMPLETE event.
                if (this._adInfo) {
                    this._adInfo = null;
                    this._adBreakInfo = null;
                }
            }
        }

        NotificationCenter().dispatchEvent(PlayerEvent.PLAYHEAD_UPDATE);
    };

    VideoPlayer.prototype._onTick = function() {

        if(this._state == "seeking" || this._state == "paused"){
            return;
        }

        var vTime = this.getPlayhead();

        //Chromecast player uses playhead 0 before and after the video plays. Ignoring playhead 0.
        if(vTime == 0){
            return
        }

        if(Math.abs(this.getDuration() - vTime) <= 1.0){
            this._reachedEnd = true;
        }

        // If we're inside the ad content:
        if (vTime >= AD_START_POS && vTime < AD_END_POS) {
            if (this._chapterInfo) {
                // If we were inside a chapter, complete it.
                this._completeChapter();
            }

            if (!this._adInfo) {
                // Start the ad (if not already started).
                this._startAd();
            }
        }

        // Otherwise, we're outside the ad content:
        else {
            if (this._adInfo) {
                // Complete the ad (if needed).
                this._completeAd();
            }

            if (vTime < CHAPTER1_END_POS) {
                if (this._chapterInfo && this._chapterInfo.position != 1) {
                    // If we were inside another chapter, complete it.
                    this._completeChapter();
                }

                if (!this._chapterInfo) {
                    // Start the first chapter.
                    this._startChapter1();
                }
            } else {
                if (this._chapterInfo && this._chapterInfo.position != 2) {
                    // If we were inside another chapter, complete it.
                    this._completeChapter();
                }

                if (!this._chapterInfo) {
                    // Start the second chapter.
                    this._startChapter2();
                }
            }
        }

        NotificationCenter().dispatchEvent(PlayerEvent.PLAYHEAD_UPDATE);
    };

    // Export symbols.
    window.PlayerEvent = PlayerEvent;
    window.VideoPlayer = VideoPlayer;
})();
