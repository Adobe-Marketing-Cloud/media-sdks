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

    var StreamType = ADB.va.MediaHeartbeat.StreamType;
    var MediaHeartbeat = ADB.va.MediaHeartbeat;

    var PlayerEvent = {
        VIDEO_LOAD: 'video_load',
        VIDEO_UNLOAD: 'video_unload',
        PLAY: 'play',
        PAUSE: 'pause',
        COMPLETE: 'COMPLETE',
        BUFFER_START: 'buffer_start',
        BUFFER_COMPLETE: 'buffer_complete',
        SEEK_START: 'seek_start',
        SEEK_COMPLETE: 'seek_complete',
        AD_START: "ad_start",
        AD_COMPLETE: "ad_complete",
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

    function VideoPlayer(id) {
        this._playerName = Configuration.PLAYER.NAME;
        this._videoId = Configuration.PLAYER.VIDEO_ID;
        this._videoName = Configuration.PLAYER.VIDEO_NAME;
        this._streamType = StreamType.VOD;

        this._videoLoaded = false;

        this._adBreakInfo = null;
        this._adInfo = null;
        this._chapterInfo = null;

        // Build a static/hard-coded QoS info here.
        this._qosInfo = MediaHeartbeat.createQoSObject(50000, 0, 24, 10);

        this._clock = null;

        this.el = document.getElementById(id);

        var self = this;
        if (this.el) {
            this.el.addEventListener('playing', function() {
                self._onPlay();
            });
            this.el.addEventListener('seeking', function() {
                self._onSeekStart();
            });
            this.el.addEventListener('seeked', function() {
                self._onSeekComplete();
            });
            this.el.addEventListener('pause', function() {
                self._onPause();
            });
            this.el.addEventListener('ended', function() {
                self._onComplete();
            });
        }
    }

    VideoPlayer.prototype.getCurrentPlaybackTime = function() {
        var playhead;        
        var vTime = this.getPlayhead();
        if(vTime > AD_START_POS + AD_LENGTH) {
            playhead = vTime - AD_LENGTH;
        } else if(vTime > AD_START_POS){
            playhead = AD_START_POS;
        } else {
            playhead = vTime;
        }            
        return playhead;
    };

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
        return this.el.duration - AD_LENGTH;
    };

    VideoPlayer.prototype.getPlayhead = function() {
        var playhead = this.el.currentTime;
        return playhead ? playhead : 0;
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
        this._videoInfo = {};
        this._videoInfo.id = this._videoId;
        this._videoInfo.name = this._videoName;
        this._videoInfo.playerName = this._playerName;
        this._videoInfo.length = this.getDuration();
        this._videoInfo.streamType = this._streamType;
        this._videoInfo.playhead = this.getPlayhead();

        this._videoLoaded = true;

        NotificationCenter().dispatchEvent(PlayerEvent.VIDEO_LOAD);
    };

    VideoPlayer.prototype._startChapter1 = function() {
        // Prepare the chapter info.
        this._chapterInfo = {};
        this._chapterInfo.length = CHAPTER1_LENGTH;
        this._chapterInfo.startTime = CHAPTER1_START_POS;
        this._chapterInfo.position = 1;
        this._chapterInfo.name = "First chapter";

        NotificationCenter().dispatchEvent(PlayerEvent.CHAPTER_START);
    };

    VideoPlayer.prototype._startChapter2 = function() {
        // Prepare the chapter info.
        this._chapterInfo = {};
        this._chapterInfo.length = CHAPTER2_LENGTH;
        this._chapterInfo.startTime = CHAPTER2_START_POS;
        this._chapterInfo.position = 2;
        this._chapterInfo.name = "Second chapter";

        NotificationCenter().dispatchEvent(PlayerEvent.CHAPTER_START);
    };

    VideoPlayer.prototype._completeChapter = function() {
        // Reset the chapter info.
        this._chapterInfo = null;

        NotificationCenter().dispatchEvent(PlayerEvent.CHAPTER_COMPLETE);
    };

    VideoPlayer.prototype._startAd = function() {
        // Prepare the ad break info.
        this._adBreakInfo = {};
        this._adBreakInfo.name = "First Ad-Break";
        this._adBreakInfo.position = 1;
        this._adBreakInfo.playerName = this._playerName;
        this._adBreakInfo.startTime = AD_START_POS;

        // Prepare the ad info.
        this._adInfo = {};
        this._adInfo.id = "001";
        this._adInfo.name = "Sample ad";
        this._adInfo.length = AD_LENGTH;
        this._adInfo.position = 1;

        // Start the ad.
        NotificationCenter().dispatchEvent(PlayerEvent.AD_START);
    };

    VideoPlayer.prototype._completeAd = function() {
        // Complete the ad.
        NotificationCenter().dispatchEvent(PlayerEvent.AD_COMPLETE);

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
    };

    VideoPlayer.prototype._onTick = function() {
        if (this.el.seeking || this.el.paused) {
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
    };

    // Export symbols.
    window.PlayerEvent = PlayerEvent;
    window.VideoPlayer = VideoPlayer;
})();
