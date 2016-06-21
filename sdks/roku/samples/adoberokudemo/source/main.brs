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

Sub Main()

	ADBMobile().setDebugLogging(false)
	
    dictionary = { }
    dictionary["app"] = "Adobe Sample"
    dictionary["version"] = "1.0.0"
	ADBMobile().trackState("Launch Screen", dictionary)
	ADBMobile().trackAction("Launch Action", dictionary)
	
    initTheme()
	initCategoryList()
    showHomeScreen()

End Sub

Function initCategoryList() As Void
    m.items = InitCatalog()
End Function

Function showHomeScreen()

    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
	
    screen.SetMessagePort(port)
    screen.SetListStyle("flat-category")
    screen.SetAdDisplayMode("scale-to-fit")	
    screen.SetContentList(m.items)
    screen.Show()
	
    dictionary = { }
    dictionary["app"] = "Adobe Sample"
    dictionary["version"] = "1.0.0"
	ADBMobile().trackState("Home Screen", dictionary)

    while true
        msg = wait(100, screen.GetMessagePort())
		
        ' Call this in the main event loop
        ADBMobile().processMessages()

        if type(msg) = "roPosterScreenEvent" then
            print "showHomeScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
            if msg.isListFocused() then
                print "list focused | index = "; msg.GetIndex(); " | category = "; m.curCategory
            else if msg.isListItemSelected() then
                print "list item selected | index = "; msg.GetIndex()
				
			    dictionary = { }
			    dictionary["app"] = "Adobe Sample"
			    dictionary["version"] = "1.0.0"				
				ADBMobile().trackAction("Show Details Selected", dictionary)
				
                displayShowDetailScreen(m.items, msg.GetIndex())
            else if msg.isScreenClosed() then
                return -1
            end if
        end If
    end while

End Function

Function displayShowDetailScreen(showList As Object, showIndex as Integer) As Dynamic

    port = CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")
    screen.SetDescriptionStyle("video") 
    screen.SetMessagePort(port)
	
    showIndex = showDetailScreen(screen, showList, showIndex)

    return 0
End Function

Function initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")
	theme.BackgroundColor = "#AAAAAA"

    app.SetTheme(theme)

End Function