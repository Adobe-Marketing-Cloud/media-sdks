/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2018 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */
'use strict';
(function() {

  if (typeof ADB === 'undefined') {
    if (window && window.console && window.console.warn) {
      console.warn('MediaHeartbeat exports are not found. \
Make sure to include the Launch library to index.html and \
configure Adobe Analytics for Video extension to export APIs to window object named \"ADB\".');
      return;
    }
  }
  var MediaHeartbeat = ADB.MediaHeartbeat;
  var MediaHeartbeatDelegate = ADB.MediaHeartbeatDelegate;

  // The VA Launch extension returns a Promise based API to create an instance of MediaHeartbeat.
  // This helper tries to reuse existing code by queuing events till the Promise completes.
  // Use the Promise based API directly for more control on handling errors.
  var MediaHeartbeatAdapter = (function(MediaHeartbeat) {
    function MediaHeartbeatAdapter(delegate, config) {
      this._queuedAPICalls = [];
      this._tracker = null;
      this._creatingTracker = true;
      this._internalError = false;

      var self = this;
      MediaHeartbeat.getInstance(delegate, config).then(function(tracker) {
        self._creatingTracker = false;
        self._tracker = tracker;

        self._queuedAPICalls.forEach(function(apiCall) {
          self[apiCall].apply(self._tracker, apiCall.arguments);
        });
      }).catch(function(error) {
        console.log(error);
        self._internalError = true;
      });
    }

    var apis = ['trackSessionStart', 'trackSessionEnd', 'trackComplete', 'trackPlay', 'trackPause', 'trackEvent', 'trackError'];
    apis.forEach(function(api) {
      MediaHeartbeatAdapter.prototype[api] = function() {
        if (this._internalError) {
          console.log('Error creating MediaHeartbeat instance. API call is dropped.');
          return;
        }

        if (this._creatingTracker) {
          console.log('Creating MediaHeartbeat instance. Queuing current API call.');
          this._queuedAPICalls.push({
            name : api,
            arguments : arguments
          });
          return;
        }

        this._tracker[api].apply(this._tracker, arguments);
      };
    });
    return MediaHeartbeatAdapter;
  })(MediaHeartbeat);

  function VideoAnalyticsProvider(player) {
    if (!player) {
      throw new Error('Illegal argument. Player reference cannot be null.');
    }
    this._player = player;

    function SampleMediaHeartbeatDelegate(player) {
      this._player = player;
    }
    // Implement the sample MediaHeartbeatDelegate to provide Playhead information and QoS information from the player
    SampleMediaHeartbeatDelegate.prototype = Object.create(MediaHeartbeatDelegate.prototype);
    SampleMediaHeartbeatDelegate.prototype.constructor = SampleMediaHeartbeatDelegate;

    SampleMediaHeartbeatDelegate.prototype.getCurrentPlaybackTime = function() {
      return this._player.getCurrentPlaybackTime();
    };

    SampleMediaHeartbeatDelegate.prototype.getQoSObject = function() {
      var qosInfo = this._player.getQoSInfo();
      return MediaHeartbeat.createQoSObject(qosInfo.bitrate, 
        qosInfo.startupTime, 
        qosInfo.fps, 
        qosInfo.droppedFrames);
    };

    this._mediaHeartbeat = new MediaHeartbeatAdapter(new SampleMediaHeartbeatDelegate(this._player));

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
      isUserLoggedIn: 'false',
      tvStation: 'Sample TV station',
      programmer: 'Sample programmer'
    };

    var videoInfo = this._player.getVideoInfo();
    var mediaInfo = MediaHeartbeat.createMediaObject(videoInfo.name,
      videoInfo.id,
      videoInfo.length,
      MediaHeartbeat.StreamType.VOD,
      MediaHeartbeat.MediaType.Video);

    //Set to true if this is a resume playback scenario (not starting from playhead 0)
    //mediaInfo.setValue(MediaHeartbeat.MediaObjectKey.VideoResumed, true);

    // Set standard Video Metadata
    var standardVideoMetadata = {};
    standardVideoMetadata[MediaHeartbeat.VideoMetadataKeys.EPISODE] = 'Sample Episode';
    standardVideoMetadata[MediaHeartbeat.VideoMetadataKeys.SHOW] = 'Sample Show';

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
      affiliate: 'Sample affiliate',
      campaign: 'Sample ad campaign'
    };

    // AdBreak Info - getting the adBreakInfo from player and creating AdBreakInfo Object from MediaHeartbeat
    var _adBreakInfo = this._player.getAdBreakInfo();
    var adBreakInfo = MediaHeartbeat.createAdBreakObject(_adBreakInfo.name, _adBreakInfo.position, _adBreakInfo.startTime);

    // Ad Info - getting the adInfo from player and creating AdInfo Object from MediaHeartbeat
    var _adInfo = this._player.getAdInfo();
    var adInfo = MediaHeartbeat.createAdObject(_adInfo.name, _adInfo.id, _adInfo.position, _adInfo.length);

    // Set standard Ad Metadata
    var standardAdMetadata = {};
    standardAdMetadata[MediaHeartbeat.AdMetadataKeys.ADVERTISER] = 'Sample Advertiser';
    standardAdMetadata[MediaHeartbeat.AdMetadataKeys.CAMPAIGN_ID] = 'Sample Campaign';

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
      segmentType: 'Sample segment type'
    };

    // Chapter Info - getting the chapterInfo from player and creating ChapterInfo Object from MediaHeartbeat
    var _chapterInfo = this._player.getChapterInfo();
    var chapterInfo = MediaHeartbeat.createChapterObject(_chapterInfo.name,
      _chapterInfo.position,
      _chapterInfo.length,
      _chapterInfo.startTime);

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
