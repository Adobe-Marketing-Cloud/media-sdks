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
 
 
Function showVideoContent(content As Object)

    port = CreateObject("roMessagePort")
    screen = CreateObject("roVideoScreen")
    screen.SetMessagePort(port)

    screen.SetPositionNotificationPeriod(1)
    screen.SetContent(content)
    screen.Show()
    setAdBreaks(content.adbreaks)
    setChapters(content.chapters) 

    m["playheadPosition"] = 0

    'uncomment next line to print content
    'PrintAA(content)
	
    dictionary = { }
    dictionary["app"] = "Adobe Sample"
    dictionary["version"] = "1.0.0"
	ADBMobile().trackState("Video Screen", dictionary)
	ADBMobile().trackAction("Play Pressed", dictionary)	
	
	''' Send the content object as is
	
    mediaContextData = { }
    mediaContextData["videotype"] = "episode"
    
    standaradMetadata = {}
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeySHOW] = "sample show"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeySEASON] = "sample season"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyEPISODE] = "sample episode"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyASSET_ID] = "sample asset id"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyGENRE] = "sample genre"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyFIRST_AIR_DATE] = "sample first_air_date"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyFIRST_DIGITAL_DATE] = "sample first_digital_date"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyRATING] = "sample rating"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyORIGINATOR] = "sample originator"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyNETWORK] = "sample network"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeySHOW_TYPE] = "sample show type"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyAD_LOAD] = "sample ad load"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyMVPD] = "sample mvpd"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyAUTHORIZED] = "sample authorized"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyDAY_PART] = "sample day_part"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeyFEED] = "sample feed"
    standaradMetadata[ADBMobile().MEDIA_VideoMetadataKeySTREAM_FORMAT] = "sample format"

    content[ADBMobile().MEDIA_STANDARD_VIDEO_METADATA] = standaradMetadata
	
    ADBVideoPlayer().setContent(content, mediaContextData)

    while true
        msg = wait(100, port)
		
		''' Let ADBVideoPlayer handle the message first
		ADBVideoPlayer().handleMessage(msg)
		
        ''' Run the process messages handler for ADB Media
        ADBMobile().processMediaMessages()        

        if type(msg) = "roVideoScreenEvent" then
            if msg.isScreenClosed()
                exit while
            elseif msg.isRequestFailed()
            elseif msg.isStatusMessage()
            elseif msg.isButtonPressed()
            elseif msg.isPlaybackPosition() then
                handleTimeline(msg.GetIndex())
            end if
        else
            'print "Unexpected message class: "; type(msg)
        end if
    end while
End Function

 
Function currentPlaybackContext() As Object
    if GetGlobalAA().appPlaybackContext = invalid
        instance = {

            setCurrAdBreak: Function(adBreak As Object) As Void
                m.currAdBreak = adBreak
            End Function,

            getCurrAdBreak: Function() As Object
                return m.currAdBreak
            End Function,

            setCurrAd: Function(ad As Object) As Void
                 m.currAd = ad
            End Function,

            getCurrAd: Function() As Object
                return m.currAd
            End Function,

            setCurrChapter: Function(chapter As Object) As Void
                m.currChapter = chapter
            End Function,

            getCurrChapter: Function() As Object
                return m.currChapter
            End Function,

            setCurrAdBreakInfo: Function(adBreakInfo As Object) As Void
                m.currAdBreakInfo = adBreakInfo
            End Function,

            getCurrAdBreakInfo : Function() As Object
                return m.currAdBreakInfo
            End Function,

            setCurrAdInfo: Function(adInfo As Object) As Void
                m.currAdInfo = adInfo
            End Function,

            getCurrAdInfo : Function() As Object
                return m.currAdInfo
            End Function,

            isInChapter: Function() As Boolean
                if m.currChapter<> invalid
                    return true
                endif

                return false
            End Function,

            isInAdBreak: Function() As Boolean
                if m.currAdBreakInfo <> invalid
                    return true
                endif

                return false
            End Function,

            isInAd: Function() As Boolean
                if m.currAdInfo <> invalid
                    return true
                endif

                return false
            End Function
        }

        GetGlobalAA().appPlaybackContext = instance

    endif

    return GetGlobalAA().appPlaybackContext
End Function


Function setAdBreaks(content As Object)
    m.currAdBreaks = content
End Function


Function setChapters(content As Object)
    m.currChapters = content
End Function


Function getAdBreaks() As Object
    return m.currAdBreaks
End Function


Function getChapters() As Object
    return m.currChapters
End Function


Function handleTimeline(position As Integer)

  positionDelta = position - m["playheadPosition"]
  if position <> invalid AND (positionDelta > 0 OR positionDelta <= -3)
    m["playheadPosition"] = position
  endif    
  
  handleAdBreaks(m["playheadPosition"])
  handleChapters(m["playheadPosition"])
  
End Function


Function handleAdBreaks(position As Integer)
    '?"======== handleTimeline position: " position

    if currentPlaybackContext().isInAdBreak() = false
        ?"Check if position falls in any ad break boundary"

        currAdBreaks = getAdBreaks()
        if currAdBreaks <> invalid
            for each adBreak in currAdBreaks
                adBreakStartTime = adBreak.startupTime
                adBreakEndTime = adBreakStartTime + adBreak.duration
                
                ?"In Ad Break range? adBreakStartTime: " adBreakStartTime
                ?"In Ad Break range? adBreakEndTime: " adBreakEndTime

                if position >= adBreakStartTime and position < adBreakEndTime
                        ?"Landed in Break range"
                        adBreakInfo = adb_media_init_adbreakinfo("pod1", adBreakStartTime, adBreak.breakNumber)

                        ADBMobile().mediaTrackEvent(ADBMobile().MEDIA_AD_BREAK_START, adBreakInfo, invalid)
                        currentPlaybackContext().setCurrAdBreakInfo(adBreakInfo)
                        currentPlaybackContext().setCurrAdBreak(adBreak)
                        exit for
                endif
            next
        endif
    endif
    
    if currentPlaybackContext().isInAdBreak() = true
        ?" In ad break? Check if any ad started / finished / break finished"
        
        currAdBreak = currentPlaybackContext().getCurrAdBreak()
        currAdBreakStartTime = currAdBreak.startupTime
        currAdBreakEndTime = currAdBreakStartTime + currAdBreak.duration

        if currentPlaybackContext().isInAd() = false
            for each ad in currAdBreak.ads
                ?"In Ad range? adStarttime: " ad.startupTime
                ?"In Ad range? position: " position
                ?"In Ad range? adEndtime: " ad.endTime
                ?"In Ad range? isInAd()?: " currentPlaybackContext().isInAd()

                if position >= ad.startupTime and position < ad.endTime
                    adInfo = adb_media_init_adinfo(ad.title, ad.title, ad.position, ad.duration)
                    
                    standardAdMetadata = {}
                    standardAdMetadata[ADBMobile().MEDIA_AdMetadataKeyCAMPAIGN_ID] = "sample campaign"
                    standardAdMetadata[ADBMobile().MEDIA_AdMetadataKeyADVERTISER] = "sample advertiser"
                    standardAdMetadata[ADBMobile().MEDIA_AdMetadataKeyCREATIVE_ID] = "sample creativeid"
                    standardAdMetadata[ADBMobile().MEDIA_AdMetadataKeyPLACEMENT_ID] = "sample placement id"
                    standardAdMetadata[ADBMobile().MEDIA_AdMetadataKeySITE_ID] = "sample site id"
                    standardAdMetadata[ADBMobile().MEDIA_AdMetadataKeyCREATIVE_URL] = "sample creative url"
                    
                    adInfo[ADBMobile().MEDIA_STANDARD_AD_METADATA] = standardAdMetadata

                    currentPlaybackContext().setCurrAdInfo(adInfo)
                    currentPlaybackContext().setCurrAd(ad)
                    ADBMobile().mediaTrackEvent(ADBMobile().MEDIA_AD_START, adInfo, ad.contextData)
                    exit for
                endif
            next
        else if currentPlaybackContext().isInAd() = true
            'check for current ad's exit condition
            currAd = currentPlaybackContext().getCurrAd()

            ?"Out of Ad range? adEndtime: " currAd.endTime
            if position >= currAd.endTime
                adInfo = currentPlaybackContext().getCurrAdInfo()
                currentPlaybackContext().setCurrAdInfo(invalid)
                currentPlaybackContext().setCurrAd(invalid)
                ADBMobile().mediaTrackEvent(ADBMobile().MEDIA_AD_COMPLETE, adInfo, currAd.contextData)
            endif
        endif

        
        'check for ad break exit condition
        if position >= currAdBreakEndTime
            ?"Already in ad break? Check if the ad break finished"
            adBreakInfo = currentPlaybackContext().getCurrAdBreakInfo()
            ADBMobile().mediaTrackEvent(ADBMobile().MEDIA_AD_BREAK_COMPLETE, adBreakInfo, invalid)
            currentPlaybackContext().setCurrAdBreakInfo(invalid)
            currentPlaybackContext().setCurrAdBreak(invalid)
        endif

    endif
End Function


Function handleChapters(position As Integer)
    if currentPlaybackContext().isInChapter() = false
        currChapters = getChapters()
        if currChapters <> invalid
            for each chapter in currChapters
                chapterEndTime = chapter.offset + chapter.length
                if position >= chapter.offset and position < chapterEndTime
                    currentPlaybackContext().setCurrChapter(chapter)
                    ADBMobile().mediaTrackEvent(ADBMobile().MEDIA_CHAPTER_START, chapter, invalid)
                    exit for
                endif
            next
        endif
    endif

    if currentPlaybackContext().isInChapter() = true
        currChapter = currentPlaybackContext().getCurrChapter()
        chapterEndTime = currChapter.offset + currChapter.length
        if position >= chapterEndTime
            currentPlaybackContext().setCurrChapter(invalid)
            ADBMobile().mediaTrackEvent(ADBMobile().MEDIA_CHAPTER_COMPLETE, currChapter, invalid)
        endif
    endif


End Function