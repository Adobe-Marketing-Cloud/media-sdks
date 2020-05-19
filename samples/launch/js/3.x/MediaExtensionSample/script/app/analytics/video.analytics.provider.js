/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2014 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */
'use strict';
(function() {    

  if (typeof ADB === 'undefined') {
    if (window && window.console && window.console.error) {
      console.error('Media exports are not found. \
Make sure to include the Launch library to index.html and \
configure Adobe Media Analytics for Audio and Video extension (v2) to export APIs to window object named \"ADB\".');
      return;
    }
  }
    
  var Media = ADB.Media;

  function VideoAnalyticsProvider(player) {
    if (!player) {
      throw new Error('Illegal argument. Player reference cannot be null.');
    }
    this._player = player;


    this._mediaTracker = Media.getInstance();

    this._installEventListeners();
  }

  VideoAnalyticsProvider.prototype.destroy = function() {
    if (this._mediaTracker) {
      this._mediaTracker.destroy();
      this._mediaTracker = null;
    }

    if (this._player) {            
      this._player = null;
      this._uninstallEventListeners();
    }
  };


  /////////
  // Notification handlers
  /////////

  VideoAnalyticsProvider.prototype._onLoad = function() {
    console.log('Player event: VIDEO_LOAD');
    var videoInfo = this._player.getVideoInfo();
    var mediaInfo = Media.createMediaObject(videoInfo.name, videoInfo.id, videoInfo.length, 
      Media.StreamType.VOD, Media.MediaType.Video);

    // Set to true if this is a resume playback scenario (not starting from playhead 0)
    // mediaInfo[Media.MediaObjectKey.MediaResumed] = true;

    var contextData = {
      isUserLoggedIn: 'false',
      tvStation: 'Sample TV station',
      programmer: 'Sample programmer'
    };
        
    // Set standard Video Metadata        
    contextData[Media.VideoMetadataKeys.Episode] = 'Sample Episode';
    contextData[Media.VideoMetadataKeys.Show] = 'Sample Show';        

    this._mediaTracker.trackSessionStart(mediaInfo, contextData);
  };

  VideoAnalyticsProvider.prototype._onUnload = function() {
    console.log('Player event: VIDEO_UNLOAD');
    this._mediaTracker.trackSessionEnd();
  };

  VideoAnalyticsProvider.prototype._onPlay = function() {
    console.log('Player event: PLAY');
    this._mediaTracker.trackPlay();
  };

  VideoAnalyticsProvider.prototype._onPause = function() {
    console.log('Player event: PAUSE');
    this._mediaTracker.trackPause();
  };

  VideoAnalyticsProvider.prototype._onSeekStart = function() {
    console.log('Player event: SEEK_START');
    this._mediaTracker.trackEvent(Media.Event.SeekStart);
  };

  VideoAnalyticsProvider.prototype._onSeekComplete = function() {
    console.log('Player event: SEEK_COMPLETE');
    this._mediaTracker.trackEvent(Media.Event.SeekComplete);
  };

  VideoAnalyticsProvider.prototype._onBufferStart = function() {
    console.log('Player event: BUFFER_START');
    this._mediaTracker.trackEvent(Media.Event.BufferStart);
  };

  VideoAnalyticsProvider.prototype._onBufferComplete = function() {
    console.log('Player event: BUFFER_COMPLETE');
    this._mediaTracker.trackEvent(Media.Event.BufferComplete);
  };

  VideoAnalyticsProvider.prototype._onAdStart = function() {
    console.log('Player event: AD_START');

    // AdBreak Info - getting the adBreakInfo from player and creating AdBreakInfo Object from MediaHeartbeat
    var _adBreakInfo = this._player.getAdBreakInfo();
    var adBreakInfo = Media.createAdBreakObject(_adBreakInfo.name, _adBreakInfo.position, _adBreakInfo.startTime);

    // Ad Info - getting the adInfo from player and creating AdInfo Object from MediaHeartbeat
    var _adInfo = this._player.getAdInfo();
    var adInfo = Media.createAdObject(_adInfo.name, _adInfo.id, _adInfo.position, _adInfo.length);

    var adContextData = {
      affiliate: 'Sample affiliate',
      campaign: 'Sample ad campaign'
    };

    // Set standard Ad Metadata        
    adContextData[Media.AdMetadataKeys.Advertiser] = 'Sample Advertiser';
    adContextData[Media.AdMetadataKeys.CampaignId] = 'Sample Campaign';

    this._mediaTracker.trackEvent(Media.Event.AdBreakStart, adBreakInfo);
    this._mediaTracker.trackEvent(Media.Event.AdStart, adInfo, adContextData);
  };

  VideoAnalyticsProvider.prototype._onAdComplete = function() {
    console.log('Player event: AD_COMPLETE');
    this._mediaTracker.trackEvent(Media.Event.AdComplete);
    this._mediaTracker.trackEvent(Media.Event.AdBreakComplete);
  };

  VideoAnalyticsProvider.prototype._onChapterStart = function() {
    console.log('Player event: CHAPTER_START');
    var chapterContextData = {
      segmentType: 'Sample segment type'
    };

    // Chapter Info - getting the chapterInfo from player and creating ChapterInfo Object from MediaHeartbeat
    var _chapterInfo = this._player.getChapterInfo();
    var chapterInfo = Media.createChapterObject(_chapterInfo.name, _chapterInfo.position, 
      _chapterInfo.length, _chapterInfo.startTime);

    this._mediaTracker.trackEvent(Media.Event.ChapterStart, chapterInfo, chapterContextData);
  };

  VideoAnalyticsProvider.prototype._onChapterComplete = function() {
    console.log('Player event: CHAPTER_COMPLETE');
    this._mediaTracker.trackEvent(Media.Event.ChapterComplete);
  };

  VideoAnalyticsProvider.prototype._onComplete = function() {
    console.log('Player event: COMPLETE');
    this._mediaTracker.trackComplete();
  };

  VideoAnalyticsProvider.prototype._onPlayheadUpdate = function() {
    //console.log('Player event: PLAYHEAD_UPDATE');
    var playhead = this._player.getCurrentPlaybackTime();
    this._mediaTracker.updatePlayhead(playhead);
  };

  VideoAnalyticsProvider.prototype._onQoEUpdate = function() {
    console.log('Player event: QOE_UPDATE');
    var _qoeInfo = this._player.getQoEInfo();
    var qoeInfo = Media.createQoEObject(_qoeInfo.bitrate, _qoeInfo.startupTime, _qoeInfo.fps, _qoeInfo.droppedFrames);

    this._mediaTracker.updateQoEObject(qoeInfo);
  };

  VideoAnalyticsProvider.prototype._onMuteChange = function() {
    var muted = this._player.isMuted();
    console.log('Player event: MUTE_CHANGE to ' + muted);

    var info = Media.createStateObject(Media.PlayerState.Mute);
    var event = muted ? Media.Event.StateStart : Media.Event.StateEnd;

    this._mediaTracker.trackEvent(event, info);
  };
    

  VideoAnalyticsProvider.prototype._onFullscreenChange = function() {
    var fullscreen = this._player.isFullscreen();
    console.log('Player event: FULLSCREEN_CHANGE to ' + fullscreen);

    var info = Media.createStateObject(Media.PlayerState.FullScreen);
    var event = fullscreen ? Media.Event.StateStart : Media.Event.StateEnd;

    this._mediaTracker.trackEvent(event, info);
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
    NotificationCenter().addEventListener(PlayerEvent.PLAYHEAD_UPDATE, this._onPlayheadUpdate, this);
    NotificationCenter().addEventListener(PlayerEvent.QOE_UPDATE, this._onQoEUpdate, this);
    NotificationCenter().addEventListener(PlayerEvent.MUTE_CHANGE, this._onMuteChange, this);
    NotificationCenter().addEventListener(PlayerEvent.FULLSCREEN_CHANGE, this._onFullscreenChange, this);
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
    NotificationCenter().removeEventListener(PlayerEvent.PLAYHEAD_UPDATE, this._onPlayheadUpdate, this);
    NotificationCenter().removeEventListener(PlayerEvent.QOE_UPDATE, this._onQoEUpdate, this);
    NotificationCenter().removeEventListener(PlayerEvent.MUTE_CHANGE, this._onMuteChange, this);
    NotificationCenter().removeEventListener(PlayerEvent.FULLSCREEN_CHANGE, this._onFullscreenChange, this);
  };

  // Export symbols.
  window.VideoAnalyticsProvider = VideoAnalyticsProvider;
})();