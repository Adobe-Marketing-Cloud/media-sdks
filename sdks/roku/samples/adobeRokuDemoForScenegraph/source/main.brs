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

sub Main()
	initTheme()
	showHomecreen()
end sub

sub showHomecreen()
  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.setMessagePort(m.port)
  scene = screen.CreateScene("HomeScene")
  screen.show()

  while (true)
    scene.run = scene.run + 1
    
    msg = wait(1, m.port)
    if type(msg) = "roSGScreenEvent"
      print "received screen closed...."
      if msg.isScreenClosed() then return
    end if
  end while

end sub

Function initTheme()
  app = CreateObject("roAppManager")
  theme = CreateObject("roAssociativeArray")
	theme.BackgroundColor = "#AAAAAA"
  app.SetTheme(theme)
End Function