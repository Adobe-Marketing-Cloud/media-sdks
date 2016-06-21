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

Function InitCatalog() As Object
    conn = CreateObject("roAssociativeArray")
    catalogUrl = "http://cdn.auditude.com/assets/demos/roku/rokucatalog.json"

    mp = CreateObject("roMessagePort")
    http = CreateObject("roUrlTransfer")
    http.SetMessagePort(mp)
    http.SetUrl(catalogUrl)
    http.SetRequest("GET")

    success = http.AsyncGetToString()
    catalogJsonResponse = invalid
    if success = true
        ?"success..."
        while true
            response = wait(250, mp)
            if type(response) = "roUrlEvent" AND response.GetResponseCode() = 200
                responseString = response.GetString()
                '?"responseString..." responseString
                catalogJsonResponse = ParseJson(responseString)
                if catalogJsonResponse = invalid
                    ?"catalog download failed..... " + responseString
                endif
                exit while
            endif
        end while
    endif
    return convertJsonToList(catalogJsonResponse)
End Function

Function convertJsonToList(jsonObject As Object) As Object
    result = CreateObject("roArray", 100, true)
    
    if jsonObject <> invalid
        if jsonObject.contentList <> invalid
            itemArray = jsonObject.contentList
        endif

        for each item in itemArray
            showitem = init_show_item()

            stream = item.stream
            if stream <> invalid
                manifests = stream.manifests
                if manifests <> invalid
                    manifest = manifests[0]
                    if manifest <> invalid
                        url = manifest.url
                        showitem.StreamUrls.Push(validstr(url))
                    endif
                endif

                metadata = stream.metadata
                if metadata <> invalid
                    adBreaks = metadata["ad-breaks"]
                    adBreakItems = CreateObject("roArray", 5, true) 
                    
                    if adBreaks <> invalid
                        count = 1

                        for each adBreak in adBreaks
                            adBreakItem = init_adBreak_Item()
                            adBreakItem.breakNumber = count
                            adBreakItem.startupTime = adBreak.time / 1000
                            adBreakItem.title = adBreak.tag

                                breakAds = adBreak["ad-list"]
                                if breakAds <> invalid
                                    adBaseStartupTime = adBreakItem.startupTime
                                    totalAdsDuration = 0
                                    adCount = 0
                                    adItems = CreateObject("roArray", 5, true) 

                                    for each ad in breakAds
                                        adItem = init_ad_Item()
                                        adCount = adCount + 1
                                        adItem.startupTime = adBaseStartupTime + totalAdsDuration
                                        adItem.duration = ad.duration / 1000
                                        totalAdsDuration = totalAdsDuration + adItem.duration
                                        adItem.endTime = adItem.startupTime + adItem.duration
                                        adItem.title = ad.tag
                                        adItem.position = adCount
                                        adItems.push(adItem)
                                    next
                                    adBreakItem.duration = totalAdsDuration
                                    adBreakItem.ads = adItems
                                endif
                            
                            count = count + 1
                            adBreakItems.push(adBreakItem)
                        
                        next
                        showitem.adBreaks = adBreakItems
                    endif
                endif

                if metadata <> invalid
                    va = metadata["video-analytics"]
                    if va <> invalid
                        chapters = va.chapters
                        chapterInfoObjects = CreateObject("roArray", 5, true)

                        if chapters <> invalid
							i = 1
                            for each chapter in chapters
                                chapterInfo = adb_media_init_chapterinfo(chapter.name, i, chapter.end - chapter.start, chapter.start)
                                chapterInfoObjects.push(chapterInfo)
								i = i + 1
                            next
                            showitem.chapters = chapterInfoObjects
                        endif
                    endif

                endif

            endif

            ?"------------- ad breaks parsed ---------------" 
            ?showitem.adBreaks

            brs = item.bitrates
            if brs = invalid
                br = "1500"
                brInteger = strtoi(br)
                showitem.StreamBitrates.Push(brInteger)
            else
                for each br in brs
                    showitem.StreamBitrates.Push(strtoi(br))
                next
            endif

            sqs = item.streamQualities
            if sqs = invalid
                sq = "default-screen-quality"
                showitem.StreamQualities.Push(sq)
            else
                for each sq in sqs
                    showitem.StreamQualities.Push(validstr(sq))
                next
            endif

            title = item.title
            if title <> invalid
                showitem.Title = item.title
            endif

            contenttype = item.type
            if contenttype <> invalid
                showitem.ContentType = contenttype
            endif

            id = item.id
            if id <> invalid
                showitem.ContentId = item.id
            endif

            formattype = item.format
            if formattype <> invalid
                showitem.streamformat = formattype
            endif
			
			thumbnail = item.thumbnail
			if thumbnail <> invalid
				showitem.SDPosterUrl = thumbnail
				showitem.HDPosterUrl = thumbnail
			endif

			showitem.ShortDescriptionLine1 = showitem.Title
			showitem.Length = 600
			'showitem.Live = true
            result.push(showitem)
        next
    end if

    return result
End Function

Function init_adBreak_Item() As Object
    o = CreateObject("roAssociativeArray")
    o.breakNumber = -1
    o.startupTime = -1
    o.title = "default-ad-break"
    o.duration = -1
    o.ads = invalid 
    return o
End Function

Function init_ad_Item() As Object
    o = CreateObject("roAssociativeArray")
    o.startupTime = -1
    o.duration = -1
    o.endTime = -1
    o.title = "default-ad"
    o.position = 0
    return o
End Function

Function init_show_item() As Object
    o = CreateObject("roAssociativeArray")

    o.ContentId        = ""
    o.Title            = ""
    o.ContentType      = ""
    o.ContentQuality   = ""
    o.Synopsis         = ""
    o.Genre            = ""
    o.Runtime          = ""
    o.StreamQualities  = CreateObject("roArray", 5, true) 
    o.StreamBitrates   = CreateObject("roArray", 5, true)
    o.StreamUrls       = CreateObject("roArray", 5, true)
    o.streamformat     = "mp4"
    o.adBreaks         = invalid

    return o
End Function