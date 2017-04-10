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

'************
'CONSTRUCTOR
'************

Function initMediaTracker(mobileTracker as Object)
    m.tracker = mobileTracker
End Function

'************
'ANALYTICS
'************

Function trackAction(actionName as String, actionData as Object)
    m.tracker.actionEventName = actionName
    m.tracker.actionEventData = actionData
    m.tracker.trackAction = true
End Function

Function trackState(stateName as String, stateData as Object)
    m.tracker.stateEventName = stateName
    m.tracker.stateEventData = stateData
    m.tracker.trackState = true
End Function

Function debugLogging(flag as Boolean)
    m.tracker.debugLogs = flag
End Function

Function trackingIdentifier() as String
    return m.tracker.trackingIdentifier
End Function

Function userIdentifier() as String
    return m.tracker.userIdentifier
End Function

Function setPrivacyStatus(status as String)
    m.tracker.privacyStatus = status
End Function

Function getPrivacyStatus() as String
    return m.tracker.privacyStatus
End Function


'************
'MEDIA
'************

Function trackMediaQos(qosData as Object)
    m.tracker.mediaQoSData = qosData
    m.tracker.mediaUpdateQoS = true
End Function

Function trackMediaLoad(contentData as Object, contextData as Object)
    if contentData <> invalid
        m.tracker.mediaContentData = contentData

        if contextData <> invalid
            m.tracker.mediaContextData = contextData
        endif

        m.tracker.mediaTrackLoad = true
    endif
End Function

Function trackMediaStart()
    m.tracker.mediaTrackStart = true     
End Function

Function trackMediaPlay()
    m.tracker.mediaTrackPlay = true
End Function

Function enableDebugLogging()
    if m.tracker.debugLogs <> true
        m.tracker.debugLogs = true
    endif
End Function

Function runMediaTracker()
    m.tracker.control = "RUN"
End Function

Function updatePlayhead(position as float)
    m.tracker.playhead = position
End Function

Function trackMediaEvent (mediaEventName as String, mediaEventInfo as Object, mediaEventContextData as Object)    
    if (mediaEventName = ADBMobile().MEDIA_BUFFER_START)
        m.tracker.mediaBufferStart = true

    elseif (mediaEventName = ADBMobile().MEDIA_BUFFER_COMPLETE)
        m.tracker.mediaBufferComplete = true

    elseif (mediaEventName = ADBMobile().MEDIA_SEEK_START)
        m.tracker.mediaSeekStart = true

    elseif (mediaEventName = ADBMobile().MEDIA_SEEK_COMPLETE)
        m.tracker.mediaSeekComplete = true

    elseif (mediaEventName = ADBMobile().MEDIA_BITRATE_CHANGE)
        m.tracker.mediaBitrateChange = true

    elseif (mediaEventName = ADBMobile().MEDIA_CHAPTER_START)
        m.tracker.mediaChapterData = mediaEventInfo
        m.tracker.mediaChapterContextData = mediaEventContextData
        m.tracker.mediaChapterStart = true

    elseif (mediaEventName = ADBMobile().MEDIA_CHAPTER_COMPLETE)
        m.tracker.mediaChapterData = mediaEventInfo
        m.tracker.mediaChapterContextData = mediaEventContextData
        m.tracker.mediaChapterComplete = true
    
    elseif (mediaEventName = ADBMobile().MEDIA_CHAPTER_SKIP)
        m.tracker.mediaChapterSkip = true
    
    elseif (mediaEventName = ADBMobile().MEDIA_AD_BREAK_START)
        m.tracker.mediaAdBreakData = mediaEventInfo
        m.tracker.mediaAdBreakContextData = mediaEventContextData
        m.tracker.mediaAdBreakStart = true
    
    elseif (mediaEventName = ADBMobile().MEDIA_AD_BREAK_COMPLETE)
        m.tracker.mediaAdBreakData = mediaEventInfo
        m.tracker.mediaAdBreakContextData = mediaEventContextData
        m.tracker.mediaAdBreakComplete = true

    
    elseif (mediaEventName = ADBMobile().MEDIA_AD_BREAK_SKIP)
        m.tracker.mediaAdBreakSkip = true
    
    elseif (mediaEventName = ADBMobile().MEDIA_AD_START)
        m.tracker.mediaAdData = mediaEventInfo
        m.tracker.mediaAdContextData = mediaEventContextData
        m.tracker.mediaAdStart = true
    
    elseif (mediaEventName = ADBMobile().MEDIA_AD_COMPLETE)
        m.tracker.mediaAdData = mediaEventInfo
        m.tracker.mediaAdContextData = mediaEventContextData
        m.tracker.mediaAdComplete = true
    
    elseif (mediaEventName = ADBMobile().MEDIA_AD_SKIP)
        m.tracker.mediaAdSkip = true
    endif 
    
End Function

Function trackError(errorMsg as String, errorCode as String)
    m.tracker.mediaErrorMessage = errorMsg
    m.tracker.mediaErrorCode = errorCode
    m.tracker.mediaTrackError = true
End Function

Function trackMediaComplete()
    m.tracker.mediaTrackComplete = true
End Function

Function trackMediaUnload()
    m.tracker.mediaTrackUnload = true
End Function

Function trackMediaPause()
    m.tracker.mediaTrackPause = true
End Function

'************
'AUDIENCE
'************

Function audienceSetDpidAndDpuuid(audienceDpid as String, audienceDpuuid as String)
    m.tracker.audienceDpid = audienceDpid
    m.tracker.audienceDpuuid = audienceDpuuid
    m.tracker.audienceSetDpidAndDpuuid = true
End Function

Function audienceSubmitSignal(traits as Object)
    m.tracker.traits = traits
    m.tracker.audienceSubmitSignal = true
End Function

Function audienceDpid() as String
    return m.tracker.audienceDpid
End Function

Function audienceDpuuid() as String
    return m.tracker.audienceDpuuid
End Function

'************
'VISITOR
'************

Function visitorSyncIdentifiers(visitorIdentifiers as Object)
    m.tracker.visitorIdentifiers = visitorIdentifiers
    m.tracker.visitorSyncIdentifiers = true
End Function

Function visitorMarketingCloudID() as String
    return m.tracker.visitorMarketingCloudID
End Function
