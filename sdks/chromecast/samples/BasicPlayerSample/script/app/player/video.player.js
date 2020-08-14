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
        CHAPTER_COMPLETE: "chapter_complete",
        MUTE_CHANGE : "mute_change",
        FULLSCREEN_CHANGE : "fullscreen_change",
        QOS_UPDATE: "qos_update"
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

    function VideoPlayer(context) {        
        this._playerManager = context.getPlayerManager();
        this._playerName = "Chromecast Sample player";
        this._streamType = ADBMobile.media.StreamType.VOD;
        this._mediaType = ADBMobile.media.MediaType.Video;

        this._videoLoaded = false;

        this._videoInfo = null;
        this._adBreakInfo = null;
        this._adInfo = null;
        this._chapterInfo = null;

        // Build a static/hard-coded QoS info here.
        this._qosInfo = {
            bitrate: 50000,
            startupTime : 1.0,
            fps: 23,
            droppedFrames: 0,
        };        
        this._clock = null;
        

        this._muted = false;
        
        var self = this;
        this._playerManager.addEventListener(cast.framework.events.EventType.PLAY, function() {
            self._onPlay();
        });

        this._playerManager.addEventListener(cast.framework.events.EventType.SEEKING, function() {
            self._onSeekStart();
        });

        this._playerManager.addEventListener(cast.framework.events.EventType.SEEKED, function() {            
            self._onSeekComplete();
        });

        this._playerManager.addEventListener(cast.framework.events.EventType.PAUSE, function() {                        
            self._onPause();
        });

        this._playerManager.addEventListener(cast.framework.events.EventType.MEDIA_FINISHED, function() {
            self._onComplete();
        });
                
        context.addEventListener(cast.framework.system.EventType.SYSTEM_VOLUME_CHANGED, function(volumeEventData) {
                var volume = volumeEventData.data;
                var mute = volume.level === 0 || volume.muted;
                if (self._muted != mute) {
                    self._muted = mute;
                    self._onMuteChange();
                }
        });
    }

    VideoPlayer.prototype.getVideoInfo = function() {
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
        return this._playerManager.getDurationSec() - AD_LENGTH;
    };

    VideoPlayer.prototype.getPlayhead = function() {
        return this._playerManager.getCurrentTimeSec();
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
    
    VideoPlayer.prototype.isMuted = function() {
        return this._muted;
    };

    VideoPlayer.prototype.isFullscreen = function() {
        return this._fullScreen;
    };

    VideoPlayer.prototype._onMuteChange = function(e) {   
        if (this._videoLoaded) {     
            NotificationCenter().dispatchEvent(PlayerEvent.MUTE_CHANGE);
        }
    };

    VideoPlayer.prototype._onFullScreenChange = function(e) {        
        if (this._videoLoaded) {
            NotificationCenter().dispatchEvent(PlayerEvent.FULLSCREEN_CHANGE);
        }
    };
    
    VideoPlayer.prototype._onPlay = function(e) {
        this._openVideoIfNecessary();
        this._paused = false;
        this._seeking = false;
        NotificationCenter().dispatchEvent(PlayerEvent.PLAY);
    };

    VideoPlayer.prototype._onPause = function(e) {
        this._paused = true;
        NotificationCenter().dispatchEvent(PlayerEvent.PAUSE);
    };

    VideoPlayer.prototype._onSeekStart = function(e) {
        this._openVideoIfNecessary();
        this._seeking = true;
        NotificationCenter().dispatchEvent(PlayerEvent.SEEK_START);
    };

    VideoPlayer.prototype._onSeekComplete = function(e) {
        this._seeking = false;
        this._doPostSeekComputations();
        NotificationCenter().dispatchEvent(PlayerEvent.SEEK_COMPLETE);
    };

    VideoPlayer.prototype._onComplete = function(e) {
        this._completeVideo();
    };
    

    VideoPlayer.prototype._openVideoIfNecessary = function() {
        if (!this._videoLoaded) {
            this._resetInternalState();

            this._startVideo();

            // Start the monitor timer.
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
    };

    VideoPlayer.prototype._startVideo = function() {
        // Prepare the main video info.
        var media = this._playerManager.getMediaInformation();
        var id = media.contentId ? media.contentId : "Undefined video id";
        var name = media.metadata.title ? media.metadata.title : "Undefined video name";
        this._videoInfo = {
            id : id,
            name : name,
            duration: this.getDuration(),
            streamType : this._streamType,
            mediaType : this._mediaType
        }        
        this._videoLoaded = true;

        NotificationCenter().dispatchEvent(PlayerEvent.VIDEO_LOAD);

        NotificationCenter().dispatchEvent(PlayerEvent.QOS_UPDATE);

         if (this._muted) {
            this._onMuteChange();
        }        
    };

    VideoPlayer.prototype._startChapter1 = function() {
        // Prepare the chapter info.
        this._chapterInfo = {
            name : "First Chapter",
            position: 1,
            length: CHAPTER1_LENGTH,
            startTime: CHAPTER1_START_POS
        };
        NotificationCenter().dispatchEvent(PlayerEvent.CHAPTER_START);
    };

    VideoPlayer.prototype._startChapter2 = function() {
        // Prepare the chapter info.
        this._chapterInfo = {
            name : "Second Chapter",
            position: 2,
            length: CHAPTER2_LENGTH,
            startTime: CHAPTER2_START_POS
        };        
        NotificationCenter().dispatchEvent(PlayerEvent.CHAPTER_START);
    };

    VideoPlayer.prototype._completeChapter = function() {
        // Reset the chapter info.
        this._chapterInfo = null;

        NotificationCenter().dispatchEvent(PlayerEvent.CHAPTER_COMPLETE);
    };

    VideoPlayer.prototype._startAd = function() {
        // Prepare the ad break info.
        this._adBreakInfo = {
          name :   "First Ad-Break",
          position : 1,
          startTime : AD_START_POS,
        };

        // Prepare the ad info.        
        this._adInfo =  {
            name : "Sample ad",
            id : "001",
            position : 1,
            length: AD_LENGTH   
        };
        
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
        if (this.seeking || this.paused) {
            return;
        }

        var vTime = this.getPlayhead();

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
