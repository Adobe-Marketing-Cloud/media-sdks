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


Function showDetailScreen(screen As Object, showList As Object, showIndex as Integer) As Integer

    refreshShowDetail(screen, showList, showIndex)

    'remote key id's for left/right navigation
    remoteKeyLeft  = 4
    remoteKeyRight = 5
	
    dictionary = { }
    dictionary["app"] = "Adobe Sample"
    dictionary["version"] = "1.0.0"
	ADBMobile().trackState("Show Details Screen", dictionary)
 
    while true
        msg = wait(100, screen.GetMessagePort())
		
        ' Call this in the main event loop
        ADBMobile().processMessages()

        if type(msg) = "roSpringboardScreenEvent" then
            if msg.isScreenClosed()
                print "Screen closed"
                exit while
            else if msg.isRemoteKeyPressed() 
                print "Remote key pressed"
                if msg.GetIndex() = remoteKeyLeft then
                        showIndex = getPrevShow(showList, showIndex)
                        if showIndex <> -1
                            refreshShowDetail(screen, showList, showIndex)
                        end if
                else if msg.GetIndex() = remoteKeyRight
                    showIndex = getNextShow(showList, showIndex)
                        if showIndex <> -1
                           refreshShowDetail(screen, showList, showIndex)
                        end if
                endif
            else if msg.isButtonPressed() 
                print "ButtonPressed"

                if msg.GetIndex() = 1
                    showVideoContent(showList[showIndex])
                    refreshShowDetail(screen,showList,showIndex)
                endif
                if msg.GetIndex() = 2
                    showVideoContent(showList[showIndex])
                    refreshShowDetail(screen,showList,showIndex)
                endif
                if msg.GetIndex() = 3
                endif
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
            end if
        else
            'print "Unexpected message class: "; type(msg)
        end if
    end while

    return showIndex

End Function


Function refreshShowDetail(screen As Object, showList As Object, showIndex as Integer) As Integer

    show = showList[showIndex]

    screen.ClearButtons()
    screen.addbutton(2,"Play")
    screen.SetContent(show)
    screen.Show()

End Function


Function getNextShow(showList As Object, showIndex As Integer) As Integer

    nextIndex = showIndex + 1
    if nextIndex >= showList.Count() or nextIndex < 0 then
       nextIndex = 0 
    end if

    show = showList[nextIndex]

    return nextIndex
End Function


Function getPrevShow(showList As Object, showIndex As Integer) As Integer

    prevIndex = showIndex - 1
    if prevIndex < 0 or prevIndex >= showList.Count() then
        if showList.Count() > 0 then
            prevIndex = showList.Count() - 1 
        else
            return -1
        end if
    end if

    show = showList[prevIndex]

    return prevIndex
End Function