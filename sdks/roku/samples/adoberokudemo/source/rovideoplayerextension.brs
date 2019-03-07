' *************************************************************************
' *
' * ADOBE CONFIDENTIAL
' * ___________________
' *
' *  Copyright 2015 Adobe Systems Incorporated
' *  All Rights Reserved.
' *
' * NOTICE:  All information contained herein is, and remains
' * the property of Adobe Systems Incorporated and its suppliers,
' * if any.  The intellectual and technical concepts contained
' * herein are proprietary to Adobe Systems Incorporated and its
' * suppliers and are protected by trade secret or copyright law.
' * Dissemination of this information or reproduction of this material
' * is strictly forbidden unless prior written permission is obtained
' * from Adobe Systems Incorporated.
' *
' **************************************************************************

'@deprecated will be replaced by SceneGraph equivalent VideoPlayer wrapper node
Function ADBVideoPlayer()
  this = m.handler_Instance
  if this = INVALID

    _adb_logger().warning("ADBVideoPlayer - This utility object is deprecated and is only available for applications not using SceneGraph")

    this = {
    'member variables
      playerId   		: INVALID
      hbInitialized 	: false

    'Functions
      handleMessage   : _adb_player_HandleMessage
      setContent		: _adb_player_SetContent
    }

    ' singleton
    m.handler_Instance = this
  endif

  return this

End Function

Function _adb_player_SetContent(content as Object, ContextData as Object) as Boolean

  mInfo = adb_media_init_mediainfo(content.title, content.contentid, 0, ADBMobile().MEDIA_STREAM_TYPE_VOD, ADBMobile().MEDIA_TYPE_VIDEO)

  if content.length <> invalid
    mInfo.length = content.length
  endif

  if (content.live <> invalid and content.live = true)
    mInfo.streamType = ADBMobile().MEDIA_STREAM_TYPE_LIVE
  endif

  if content[ADBMobile().MEDIA_STANDARD_VIDEO_METADATA] <> invalid
    mInfo[ADBMobile().MEDIA_STANDARD_VIDEO_METADATA] = content[ADBMobile().MEDIA_STANDARD_VIDEO_METADATA]
  endif

  m["contentInfo"] = mInfo
  m["contextData"] = ContextData

End Function

Function _adb_player_HandleMessage(msg as Object) as Boolean

  if type(msg) = "roVideoScreenEvent" OR type(msg) = "roVideoPlayerEvent" then
    _adb_logger().debug("[ADBVideoPlayer] _adb_player_HandleMessage: msg = " + msg.GetMessage())

    if msg.isStreamStarted()

      _adb_logger().debug("[ADBVideoPlayer] isStreamStarted: " + " msg: " + msg.GetMessage())

      ' isStreamStarted after HB initialization is a return event from pause/seek event, hence trackPlay to resume HB tracking.
      if (m.hbInitialized = true)
        ADBMobile().mediaTrackPlay()
      endif

    elseif msg.isFullResult()

      _adb_logger().debug("[ADBVideoPlayer] is Full Result: " + " msg: " + msg.GetMessage())

      ADBMobile().mediaTrackComplete()

    elseif msg.isPartialResult()

      _adb_logger().debug("[ADBVideoPlayer] is Partial Result: " + " msg: " + msg.GetMessage())

    elseif msg.isPaused()

      _adb_logger().debug("[ADBVideoPlayer] is Paused: " + " msg: " + msg.GetMessage())
      ADBMobile().mediaTrackPause()

    elseif msg.isResumed()

      _adb_logger().debug("[ADBVideoPlayer] is Resumed: " + " msg: " + msg.GetMessage())
      ADBMobile().mediaTrackPlay()

    elseif msg.isRequestFailed()

      _adb_logger().debug("[ADBVideoPlayer] Video request failure: " + msg.GetIndex().ToStr() + " msg: " + msg.GetMessage())
      ADBMobile().mediaTrackError(msg.GetMessage(), ADBMobile().ERROR_SOURCE_PLAYER)

    elseif msg.isStatusMessage()

      _adb_logger().debug("[ADBVideoPlayer] Video status: " + " msg: " + msg.GetMessage())

    elseif msg.isPlaybackPosition() then
      playhead = msg.GetIndex()

      ' if hb is not initialized and playhead is 0 that means first frame display and hence call trackStart
      if (m.hbInitialized = false)
        ADBMobile().mediaTrackSessionStart(m.contentInfo, m.contextData)
        ADBMobile().mediaTrackPlay()
        m.hbInitialized = true
      endif

      _adb_logger().debug("[ADBVideoPlayer] Playback Position Changed: " + playhead.ToStr())
      if (m.contentInfo.streamType = ADBMobile().MEDIA_STREAM_TYPE_LIVE)
        ADBMobile().mediaUpdatePlayhead(-1)
      else
        ADBMobile().mediaUpdatePlayhead(playhead)
      endif

    elseif msg.isScreenClosed()

      _adb_logger().debug("[ADBVideoPlayer] is Screen Closed: " + msg.GetIndex().ToStr() + " msg: " + msg.GetMessage())
      ADBMobile().mediaTrackSessionEnd()
      m.hbInitialized = false

    elseif msg.isStreamSegmentInfo()

    elseif msg.isTimedMetaData()

    else
      _adb_logger().debug("[ADBVideoPlayer] Unexpected event type: " + type(msg))
    end if
  else
    _adb_logger().debug("[ADBVideoPlayer] Unexpected message class: " + type(msg))
  end if

  return TRUE

End Function
