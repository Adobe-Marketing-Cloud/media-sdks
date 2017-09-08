' *************************************************************************
' *
' * ADOBE CONFIDENTIAL
' * ___________________
' *
' *  Copyright 2017 Adobe Systems Incorporated
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

sub init()
    m.port = createObject("roMessagePort")
    m.top.observeField("adbmobileApiCall", m.port)
    m.top.functionName = "initializeRunLoop"
    m.top.control = "RUN"
end sub

sub initializeRunLoop()

    m.adbmobile = ADBMobile()
    
    while true
        msg = wait(250, m.port)
        
        if (msg = invalid) then
            m.adbmobile.processMessages()
            m.adbmobile.processMediaMessages()
        else 
            msgType = type(msg)
    
            if msgType = "roSGNodeEvent"
                if msg.getField() = m.adbmobile.sgConstants().API_CALL
                    executeBRSApiCall(msg.getData())
                end if
            else
        	   print "adbmobileTask Error: unrecognized event type: " + msgType
            end if
        end if
    end while
end sub

function executeBRSApiCall(invocation as Object)
    args = invocation.args
    length = args.count()
    if (invocation.methodName.Instr("getter/") = 0) then        
        methodName = invocation.methodName.Replace("getter/", "")
        returnVal = m.adbmobile[methodName]()

        response = {}
        response.apiName = methodName
        response.returnValue = returnVal
        m.top["adbmobileApiResponse"] = response
    else 
        target = m.adbmobile
        methodName = invocation.methodName

        if (length = 0) then
            target[methodName]()
        else if (length = 1) then
            target[methodName](args[0])
        else if (length = 2) then
            target[methodName](args[0], args[1])
        else if (length = 3) then
            target[methodName](args[0], args[1], args[2])
        else if (length = 4) then
            target[methodName](args[0], args[1], args[2], args[3])
        end if
    end if
end function