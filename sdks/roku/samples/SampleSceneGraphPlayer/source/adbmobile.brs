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
Library "v30/bslCore.brs"

Function ADBMobile() As Object
  if GetGlobalAA().ADBMobile = invalid
    instance = {
      version: "2.2.5",
      PRIVACY_STATUS_OPT_IN: "optedin",
      PRIVACY_STATUS_OPT_OUT: "optedout",

      ''' Scene Graph support
      sgConstants: Function() as Object
          return _adbMobileSGConnector().sceneGraphConstants()
        End Function,

      getADBMobileConnectorInstance: Function(adbmobiletask as Object) as Object
          connector = _adbMobileSGConnector().getADBMobileConnectorInstance(adbmobiletask)

          ''' attach ADBMobile constants to this connector
          connector.version = m.version
          connector.PRIVACY_STATUS_OPT_IN = m.PRIVACY_STATUS_OPT_IN
          connector.PRIVACY_STATUS_OPT_OUT = m.PRIVACY_STATUS_OPT_OUT
          _adb_media_loadconstants(connector)

          return connector
        End Function,

      ''' event loop processor
      processMessages: Function() as Void
          _adb_worker().processMessage()
          _adb_audienceManager().processMessage()
          _adb_message_worker().processMessage()
        End Function,

      processMediaMessages: Function() as Void
          ' do not execute the Media processmessages loop if MediaHeartbeat is in error state
          if _adb_media_isInErrorState() = false AND NOT(_adb_media()._isMediaDisabled())

            ' call the ADB Mobile process message since media uses analytics
            m.processMessages()

            _adb_serializeAndSendHeartbeat().processMessage()
            _adb_clockservice_loop()
            _adb_taskscheduler_loop()
          endif
        End Function,

      getAllIdentifiers: Function() as String
        return _adb_identities()._getAllIdentifiers()
      End Function,

      ''' opt-in/opt-out
      setPrivacyStatus: Function(status as String) as Void
          _adb_logger().debug("ADBMobile Privacy Status changed to: " + status)
          _adb_persistenceLayer().writeValue("adbmobile_optout", status)

          if status = m.PRIVACY_STATUS_OPT_OUT
            '''purge
            _adb_worker()._clearHits()
            _adb_serializeAndSendHeartbeat()._clearHits()
            _adb_audienceManager()._clearHits()
            _adb_message_worker()._clearHits()
            _adb_identities()._resetAllIdentifiers()
          endif

        End Function,

      getPrivacyStatus: Function() as String
          optOutState = _adb_persistenceLayer().readValue("adbmobile_optout")
          if optOutState <> invalid
            return optOutState
          endif
          return _adb_config().privacyDefault
        End Function,

      setDebugLogging: Function(flag as Boolean) as Void
          _adb_logger().debugLoggingEnabled = flag
        End Function,

      getDebugLogging: Function() as Boolean
          return _adb_logger().debugLoggingEnabled
        End Function,

      ''' analytics
      trackState: Function(state As String, ContextData as Object) as Void
          _adb_trackState(state, ContextData)
        End Function,
      trackAction: Function(action As String, ContextData as Object) as Void
          _adb_trackAction(action, ContextData)
        End Function,
      trackingIdentifier: Function() as Dynamic
          return _adb_aid()["aid"]
        End Function,
      userIdentifier: Function() as Dynamic
          return _adb_config()["userIdentifier"]
        End Function,
      setUserIdentifier: Function(id as String) as Void
          _adb_config().setUserIdentifier(id)
        End Function,

      ''' visitor id service
      visitorSyncIdentifiers: Function(identifiers as Object) As Void
        _adb_visitor().idSync(identifiers)
      End Function,
      visitorMarketingCloudID: Function() as Dynamic
        return _adb_visitor()["_mid"]
      End Function,
      setAdvertisingIdentifier: Function(identifier as String) As void
        _adb_visitor().setAdvertisingIdentifier(identifier)
      End Function,

      ''' audience manager
      audienceSubmitSignal: Function(traits as Object) As Void
          _adb_audienceManager().submitSignal(traits)
        End Function,
      audienceVisitorProfile: Function() As Object
          return _adb_audienceManager().getVisitorProfile()
        End Function,
      audienceDpid: Function() As Dynamic
          return _adb_audienceManager().getDpid()
        End Function,
      audienceDpuuid: Function() As Dynamic
          return _adb_audienceManager().getDpuuid()
        End Function,

      audienceSetDpidAndDpuuid: Function(dpid as String, dpuuid as String) As Void
          _adb_audienceManager().setDpidAndDpuuid(dpid, dpuuid)
        End Function,

      ''' media/MediaHeartbeat
      mediaTrackSessionStart: Function(mediaInfo as Object, ContextData = invalid as Object) As Void
          _adb_media().trackSessionStart(mediaInfo, ContextData)
      End Function,

      mediaTrackSessionEnd: Function() As Void
          _adb_media().trackSessionEnd()
      End Function,

      mediaTrackLoad: Function(mediaInfo as Object, ContextData = invalid as Object) As Void
          _adb_media().trackLoad(mediaInfo, ContextData)
        End Function,

      mediaTrackStart: Function() As Void
          _adb_media().trackStart()
        End Function,

      mediaTrackUnload: Function() As Void
          _adb_media().trackUnload()
        End Function,

      mediaTrackPlay: Function() As Void
          _adb_media().trackPlay()
        End Function,

      mediaTrackPause: Function() As Void
          _adb_media().trackPause()
        End Function,

      mediaTrackComplete: Function() As Void
          _adb_media().trackComplete()
        End Function,

      mediaTrackError: Function(errorId As String, errorSource As String) As Void
          _adb_media().trackError(errorId, errorSource)
        End Function,

      mediaTrackEvent: Function(event as String, data = invalid as Object, ContextData = invalid as Object) As Void
          _adb_media().trackMediaEvent(event, data, ContextData)
        End Function,

      mediaUpdatePlayhead: Function(position as Integer) As Void
          _adb_media().updatePlayhead(position)
        End Function,

      mediaUpdateQoS: Function(data as Object) As Void
          _adb_media().updateQoSData(data)
        End Function
    }

	  ' Include Constants
	  _adb_media_loadconstants(instance)

    GetGlobalAA()["ADBMobile"] = instance
  endif

  return GetGlobalAA().ADBMobile
End Function
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
''' ADBMobile Scene Graph Connector
Function _adbMobileSGConnector() As Object
  if GetGlobalAA()._adbMobileSGConnector = invalid
    instance = {
      ''' Constants used to attach field variable updates to adbmobileTask node
      sceneGraphConstants: Function() As Object
        return {
          API_CALL:                     "adbmobileApiCall",
          API_RESPONSE:                 "adbmobileApiResponse",
          DEBUG_LOGGING:                "getDebugLogging",
          PRIVACY_STATUS:               "getPrivacyStatus",
          ALL_IDENTIFIERS:              "getAllIdentifiers",
          TRACKING_IDENTIFIER:          "trackingIdentifier",
          USER_IDENTIFIER:              "userIdentifier",
          VISITOR_MARKETING_CLOUD_ID:   "visitorMarketingCloudID",
          AUDIENCE_VISITOR_PROFILE:     "audienceVisitorProfile",
          AUDIENCE_DPID:                "audienceDpid",
          AUDIENCE_DPUUID:              "audienceDpuuid"
        }
      End Function,
      ''' Return an instance of this object to make API calls to ADBMobile using Scene Graph
      ''' This object maps SG API calls to ADBMobile API calls
      getADBMobileConnectorInstance: Function(adbmobiletask as Object) as Object
        return {
          adbmobileTask:          adbmobiletask
          setDebugLogging:        Function(flag as Boolean) as void
                                    m.invokeFunction("setDebugLogging", [flag])
                                  End Function,
          getDebugLogging:        Function() as void
                                    m.invokeFunction("getter/getDebugLogging", [])
                                  End Function,
          setPrivacyStatus:       Function(state as String) as void
                                    m.invokeFunction("setPrivacyStatus", [state])
                                  End Function,
          getPrivacyStatus:       Function() as void
                                    m.invokeFunction("getter/getPrivacyStatus", [])
                                  End Function,
          getAllIdentifiers:      Function() as void
                                    m.invokeFunction("getter/getAllIdentifiers", [])
                                  End Function,
          trackState:             Function(state As String, ContextData as Object) as void
                                    m.invokeFunction("trackState", [state, ContextData])
                                  End Function,
          trackAction:            Function(action As String, ContextData as Object) as void
                                    m.invokeFunction("trackAction", [action, ContextData])
                                  End Function,
          trackingIdentifier:     Function() as void
                                    m.invokeFunction("getter/trackingIdentifier", [])
                                  End Function,
          userIdentifier:         Function() as void
                                    m.invokeFunction("getter/userIdentifier", [])
                                  End Function,
          setUserIdentifier:      Function(id as String) as void
                                    m.invokeFunction("setUserIdentifier", [id])
                                  End Function,
          visitorSyncIdentifiers: Function(identifiers as Object) as void
                                    m.invokeFunction("visitorSyncIdentifiers", [identifiers])
                                  End Function,
          setAdvertisingIdentifier: Function(identifiers as String) as void
                                    m.invokeFunction("setAdvertisingIdentifier", [identifiers])
                                  End Function,
          visitorMarketingCloudID:  Function() as void
                                      m.invokeFunction("getter/visitorMarketingCloudID", [])
                                    End Function,
          audienceSubmitSignal:   Function(traits as Object) as void
                                    m.invokeFunction("audienceSubmitSignal", [traits])
                                  End Function,
          audienceVisitorProfile: Function() as void
                                    m.invokeFunction("getter/audienceVisitorProfile", [])
                                  End Function,
          audienceDpid:           Function() as void
                                    m.invokeFunction("getter/audienceDpid", [])
                                  End Function,
          audienceDpuuid:         Function() as void
                                    m.invokeFunction("getter/audienceDpuuid", [])
                                  End Function,
          audienceSetDpidAndDpuuid: Function(dpid As String, dpuuid as String) as void
                                      m.invokeFunction("audienceSetDpidAndDpuuid", [dpid, dpuuid])
                                    End Function,
          mediaTrackSessionStart: Function(mediaInfo As Object, ContextData = invalid as Object) as void
                                    m.invokeFunction("mediaTrackSessionStart", [mediaInfo, ContextData])
                                  End Function,
          mediaTrackSessionEnd:   Function() as void
                                    m.invokeFunction("mediaTrackSessionEnd", [])
                                  End Function,
          mediaTrackLoad:         Function(mediaInfo As Object, ContextData = invalid as Object) as void
                                    m.invokeFunction("mediaTrackLoad", [mediaInfo, ContextData])
                                  End Function,
          mediaTrackStart:        Function() as void
                                    m.invokeFunction("mediaTrackStart", [])
                                  End Function,
          mediaTrackUnload:       Function() as void
                                    m.invokeFunction("mediaTrackUnload", [])
                                  End Function,
          mediaTrackPlay:         Function() as void
                                    m.invokeFunction("mediaTrackPlay", [])
                                  End Function,
          mediaTrackPause:        Function() as void
                                    m.invokeFunction("mediaTrackPause", [])
                                  End Function,
          mediaTrackComplete:     Function() as void
                                    m.invokeFunction("mediaTrackComplete", [])
                                  End Function,
          mediaTrackError:        Function(errorId As String, errorSource as String) as void
                                    m.invokeFunction("mediaTrackError", [errorId, errorSource])
                                  End Function,
          mediaTrackEvent:        Function(event As String, data = invalid As Object, ContextData = invalid as Object) as void
                                    m.invokeFunction("mediaTrackEvent", [event, data, ContextData])
                                  End Function,
          mediaUpdatePlayhead:    Function(position As Integer) as void
                                    m.invokeFunction("mediaUpdatePlayhead", [position])
                                  End Function,
          mediaUpdateQoS:         Function(data as Object) as void
                                    m.invokeFunction("mediaUpdateQoS", [data])
                                  End Function,
          sceneGraphConstants:    m.sceneGraphConstants,
          invokeFunction:         Function(funcName as string, args)
                                    invocation = {}
                                    invocation.methodName = funcName
                                    invocation.args = args
                                    m.adbmobileTask[m.sceneGraphConstants().API_CALL] = invocation
                                  End Function
        }
      End Function
    }
    GetGlobalAA()["_adbMobileSGConnector"] = instance
  endif
  return GetGlobalAA()._adbMobileSGConnector
End Function

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
Function _adb_buildAndSendRequest(data, vars, timestamp)
  mutableData = {}
  mutableData.append(data)
  ''' TODO: add time since launch?
  mutableData["a.Resolution"] = _adb_deviceInfo().resolution
  mutableData["a.DeviceName"] = _adb_deviceInfo().platform
  mutableData["a.OSVersion"] = _adb_deviceInfo().operatingSystem
  mutableData["a.AppID"] = _adb_deviceInfo().appID
  ''' TODO: add privacy status?
  mutableVars = {}
  mutableVars.append(vars)
  ''' apply visitor id service variables
  mutableVars.Append(_adb_visitor().analyticsParameters())
  ''' apply aid
  aid = _adb_aid().aid
  if aid <> invalid
    mutableVars["aid"] = aid
  endif
  ''' apply vid if it exists
  if _adb_config().userIdentifier <> invalid
    mutableVars["vid"] = _adb_config().userIdentifier
  endif
  ''' apply timestamp if offline tracking is enabled
  if _adb_config().offlineTrackingEnabled = true
    mutableVars["ts"] = timestamp
  endif
  mutableVars["t"] = _adb_deviceInfo().timestring
  ''' handle var hack
  for each key in mutableData
    if type(key) <> "roString" AND type(key) <> "String"
      _adb_logger().warning("Analytics - Invalid context data key specified, skipping it")
      mutableData.Delete(key)
    elseif key.left(2) = "&&" AND Len(key) > 2
      mutableVars[key.mid(2)] = mutableData[key]
      mutableData.Delete(key)
    endif
  end for
  ''' create our query string
  encoder = _adb_urlEncoder()
  queryString = "ndh=1" + getSyncedIDString(_adb_visitor().getAllSyncedIdentifiers()) + encoder.serializeParameters(mutableVars) + encoder.serializeContextData(mutableData)
  ''' enqueue the hit
  _adb_worker().queue(queryString, timestamp)
  'check for callbacks
  thirdPartyMutableVars = mutableVars
  thirdPartyMutableData = mutableData
  _adb_messages().checkFor3rdPartyCallbacks(thirdPartyMutableVars,thirdPartyMutableData)
End Function
Function getSyncedIDString(allSyncedIdentifiers as Dynamic) as String
  responseString = ""
  if allSyncedIdentifiers <> invalid AND allSyncedIdentifiers.Count() > 0
    idString = ""
    for each idType in allSyncedIdentifiers
      idString = idString + "&" + idType + "."
      if allSyncedIdentifiers[idType] <> invalid AND allSyncedIdentifiers[idType] <> ""
        idString = idString + "&" + "id=" + allSyncedIdentifiers[idType]
      endif
       idString = idString + "&as=0" + "&" + "." + idType
    end for
    responseString = "&cid" + "." + idString + "&" +"." + "cid"
  end if
  return responseString
End Function

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
Function _adb_urlEncoder() as Object
  if GetGlobalAA()._adb_contextDataHandlerSharedInstance = invalid
    instance = {
      ''' private variables
      _urlEncoder: CreateObject("roUrlTransfer"),
      _multiplePeriodsRegex: CreateObject("roRegex", "([.]){2,}", "i"),
      _disallowedCharactersRegex: CreateObject("roRegex", "[^0-9a-zA-Z._]|^[.]{1,}|[.]{1,}$", "i"),
      ''' private Functions
      ''' adds a value to an associative array of context data
      _addValueToAA: Function(value as dynamic, cdataStructure as object, keys as object, index as integer) as Void
          numKeys = keys.Count()
          if index >= numKeys
            return
          endif
          keyName = keys[index]
          if cdataStructure[keyName] = invalid
            cdataStructure[keyName] = {}
          endif
          if numKeys - 1 = index
            cdataStructure[keyName]["v"] = value
            return
          endif
          if cdataStructure[keyName]["subValues"] = invalid
            cdataStructure[keyName]["subValues"] = {}
          endif
          m._addValueToAA(value, cdataStructure[keyName]["subValues"], keys, index+1)
        End Function,
      ''' translates context data k/v pairs into a nested structure of associative arrays
      _translateContextData: Function(dict as Object) as Object
          tempContextData = {}
          cleanedDictionary = m._cleanContextDataDictionary(dict)
          for each key in cleanedDictionary
            value = cleanedDictionary[key]
            m._addValueToAA(value, tempContextData, key.Tokenize("."), 0)
          end for
          return tempContextData
        End Function,
      ''' serializes context data encoded object into a string format suitable for url inclusion
      _serializeContextDataObject: Function(contextData as Object) as String
          returnValue = ""
          for each key in contextData
            if contextData[key]["v"] <> invalid
              returnValue = returnValue + m._serializeKeyValuePair(key, contextData[key]["v"])
            endif
            if contextData[key]["subValues"] <> invalid
              returnValue = returnValue + "&" + key + "." + m._serializeContextDataObject(contextData[key]["subValues"]) + "&." + key
            endif
          end for
          return returnValue
        End Function,
      ''' serializes a k/v pair into a url friendly format
      _serializeKeyValuePair: Function(key as dynamic, value as dynamic) as String
          valType = type(value)
          if valType = "String" OR valType="roString"
            return "&" + m._urlEncoder.Escape(key) + "=" + m._urlEncoder.Escape(value)
          elseif valType = "roInteger" OR valType = "roInt" OR valType = "Integer"
            return "&" + m._urlEncoder.Escape(key) + "=" + m._urlEncoder.Escape(value.ToStr())
          elseif valType = "roFloat" OR valType = "Float" OR valType = "Double"
            return "&" + m._urlEncoder.Escape(key) + "=" + m._urlEncoder.Escape(Str(value).Trim())
          elseif valType = "roBoolean" OR valType = "Boolean"
            if value
              return "&" + m._urlEncoder.Escape(key) + "=" + "true"
            endif
            return "&" + m._urlEncoder.Escape(key) + "=" + "false"
          endif
          return ""
        End Function,
      ''' serializes a value into a url friendly format
      _serializeValue: Function(value as dynamic) as String
          valType = type(value)
          if valType = "String" OR valType="roString"
            return m._urlEncoder.Escape(value)
          elseif valType = "roInteger" OR valType = "roInt" OR valType = "Integer"
            return m._urlEncoder.Escape(value.ToStr())
          elseif valType = "roFloat" OR valType = "Float" OR valType = "Double"
            return m._urlEncoder.Escape(Str(value).Trim())
          elseif valType = "roBoolean" OR valType = "Boolean"
            if value
              return "true"
            endif
            return "false"
          endif
          return ""
        End Function,
        ''' joins a k/v pair into k=v format
      _joinKeyValuePair: Function(key as dynamic, value as dynamic) as String
          valType = type(value)
          if valType = "String" OR valType="roString"
            return "&" + key + "=" + value
          elseif valType = "roInteger" OR valType = "roInt" OR valType = "Integer"
            return "&" + key + "=" + value.ToStr()
          elseif valType = "roFloat" OR valType = "Float" OR valType = "Double"
            return "&" + key + "=" + Str(value).Trim()
          elseif valType = "roBoolean" OR valType = "Boolean"
            if value
              return "&" + key + "=" + "true"
            endif
            return "&" + key + "=" + "false"
          endif
          return ""
        End Function,
      ''' cleans context data dictionary of keys to ensure they match the required format
      _cleanContextDataDictionary: Function(dict as Object) As Object
          newDict = {}
          for each key in dict
            newKey = m._disallowedCharactersRegex.ReplaceAll(m._multiplePeriodsRegex.ReplaceAll(key, "."), "")
            if Len(newKey) > 0
              val = dict[key]
              valType = type(val)
              if valType = "String" OR valType="roString"
                if Len(val) > 0
                  newDict[newKey] = dict[key]
                endif
              else
                newDict[newKey] = dict[key]
              endif
            endif
          end for
          return newDict
        End Function
      ''' public Functions
      ''' takes an associative array of context data k/v pairs and translates into a url-ready string
      serializeContextData: Function(contextData as object) as String
          return "&c." + m._serializeContextDataObject(m._translateContextData(contextData)) + "&.c"
        End Function,
      ''' serializes a dictionary of k/v pairs into a url query string
      serializeParameters: Function(dict as Object) as String
          queryParameters = ""
          for each key in dict
            if type(key) <> "roString" OR Len(key) = 0
              _adb_logger().warning("Analytics - Invalid key in array, ignoring")
            else
              queryParameters = queryParameters + m._serializeKeyValuePair(key, dict[key])
            endif
          end for
          return queryParameters
        End Function,
      ''' join a dictionary of k/v pairs into a string
      joinParameters: Function(dict as Object) as String
          joinedParameters = ""
          for each key in dict
            if type(key) <> "roString" OR Len(key) = 0
              _adb_logger().warning("Analytics - Invalid key in array, ignoring")
            else
              joinedParameters = joinedParameters + m._serializeKeyValuePair(key, dict[key])
            endif
          end for
          return joinedParameters
        End Function,
    }
    GetGlobalAA()["_adb_contextDataHandlerSharedInstance"] = instance
  endif
  return GetGlobalAA()._adb_contextDataHandlerSharedInstance
End Function

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
Function _adb_deviceInfo() as Object
  if GetGlobalAA()._adb_deviceInfo = invalid
    instance = {
        _init: Function() as Void
            ''' build device info
            deviceInfo = CreateObject("roDeviceInfo")
            m["resolution"] = deviceInfo.GetDisplaySize().w.ToStr() + "x" + deviceInfo.GetDisplaySize().h.ToStr()
            m["platform"] = deviceInfo.GetModel()
            m["operatingSystem"] = "Roku " + m._getRokuOSVersionString(deviceInfo)
            ''' build app id
            appInfo = CreateObject("roAppInfo")
            title = appInfo.GetTitle()
            subTitle = appInfo.GetSubTitle()
            version = appInfo.GetVersion()
            appID = title
            if Len(subTitle) > 0
              appID = appID + "(" + subTitle + ")"
            endif
            m["appID"] = appID + " " + version
            m["defaultPageName"] = title + "/" + version
            ''' timestamp string generation
            m["timestring"] = m._timestampString(deviceInfo)
          End Function,
        _getRokuOSVersionString: Function(deviceInfo as Object) As String
          rokuVersionString = ""
          if FindMemberFunction(deviceInfo,"GetOSVersion") <> Invalid
            rokuVersionObj = deviceInfo.GetOSVersion()
            ''' Use new version format for OSVersion 10.X and above
            if StrToI(rokuVersionObj.major) >= 10
              rokuVersionString = rokuVersionObj.major + "." + rokuVersionObj.minor +"."+ rokuVersionObj.revision + "-" + rokuVersionObj.build
            endif
          endif
          if rokuVersionString = ""
            ''' Support for devices with OS version < 9.2
            rokuVersionString = deviceInfo.GetVersion()
          endif
          return rokuVersionString
        End Function,
        _timestampString: Function(deviceInfo as Object) As String
            dstNow = False
            tzList = {}
            tzList ["US/Puerto Rico-Virgin Islands"]    = {diff: -4,    dst: False}
            tzList ["US/Guam"]                          = {diff: -10,   dst: False}
            tzList ["US/Samoa"]                         = {diff: -11,   dst: True}
            tzList ["US/Hawaii"]                        = {diff: -10,   dst: False}
            tzList ["US/Aleutian"]                      = {diff: -10,   dst: True}
            tzList ["US/Alaska"]                        = {diff: -9,    dst: True}
            tzList ["US/Pacific"]                       = {diff: -8,    dst: True}
            tzList ["US/Arizona"]                       = {diff: -7,    dst: False}
            tzList ["US/Mountain"]                      = {diff: -7,    dst: True}
            tzList ["US/Central"]                       = {diff: -6,    dst: True}
            tzList ["US/Eastern"]                       = {diff: -5,    dst: True}
            tzList ["Canada/Pacific"]                   = {diff: -8,    dst: True}
            tzList ["Canada/Mountain"]                  = {diff: -7,    dst: True}
            tzList ["Canada/Central Standard"]          = {diff: -6,    dst: False}
            tzList ["Canada/Central"]                   = {diff: -6,    dst: True}
            tzList ["Canada/Eastern"]                   = {diff: -5,    dst: True}
            tzList ["Canada/Atlantic"]                  = {diff: -4,    dst: True}
            tzList ["Canada/Newfoundland"]              = {diff: -3.5,  dst: True}
            tzList ["Europe/Iceland"]                   = {diff: 0,     dst: False}
            tzList ["Europe/Ireland"]                   = {diff: 0,     dst: True}
            tzList ["Europe/United Kingdom"]            = {diff: 0,     dst: True}
            tzList ["Europe/Portugal"]                  = {diff: 0,     dst: True}
            tzList ["Europe/Central European Time"]     = {diff: 1,     dst: True}
            tzList ["Europe/Greece/Finland"]            = {diff: 2,     dst: True}
            tzEntry = tzList[deviceInfo.GetTimeZone()]
            if tzEntry = Invalid : return "00/00/0000 00:00:00 0 0" : endif
            ' Return False if the current time zone does not ever observe DST, or if time zone was not found
            If tzEntry.dst
                ' Get the current time in GMT
                dt = CreateObject ("roDateTime")
                secsGmt = dt.AsSeconds ()
                ' Convert the current time to local time
                dt.ToLocalTime ()
                secsLoc = dt.AsSeconds ()
                ' Calculate the difference in seconds between local time and GMT
                secsDiff = secsLoc - secsGmt
                ' If the difference between local and GMT equals the difference in our table, then we're on standard time now
                dstDiff = tzEntry.diff * 60 * 60 - secsDiff
                If dstDiff < 0 Then dstDiff = -dstDiff
                dstNow = dstDiff > 1   ' Use 1 sec not zero as Newfoundland time is a floating-point value
            Endif
            timeValue = tzEntry.diff
            if dstNow
              timeValue = timeValue + 1
            endif
            return "00/00/0000 00:00:00 0 " + (timeValue * -60 ).ToStr()
          End Function
    }
    instance._init()
    GetGlobalAA()["_adb_deviceInfo"] = instance
  endif
  return GetGlobalAA()._adb_deviceInfo
End Function

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
Function _adb_trackInternal(action as string, data as object, timeStamp as Integer) as Void
  contextData = {}
  contextData.append(data)
  contextData["a.internalaction"] = action
  rawLinkVars = {}
  rawLinkVars["pe"] = "lnk_o"
  rawLinkVars["pev2"] = "ADBINTERNAL:" + action
  rawLinkVars["pageName"] = _adb_deviceInfo()["defaultPageName"]
  _adb_buildAndSendRequest(contextData, rawLinkVars, timeStamp)
End Function
Function _adb_trackAction(action as string, data as object) as Void
  contextData = {}
  contextData.append(data)
  contextData["a.action"] = action
  rawLinkVars = {}
  rawLinkVars["pe"] = "lnk_o"
  rawLinkVars["pev2"] = "AMACTION:" + action
  rawLinkVars["pageName"] = _adb_deviceInfo()["defaultPageName"]
  _adb_buildAndSendRequest(contextData, rawLinkVars, CreateObject("roDateTime").AsSeconds())
End Function
Function _adb_trackState(state as string, data as object) as Void
  if Len(state) = 0
    state = _adb_deviceInfo()["defaultPageName"]
  endif
  rawLinkVars = {}
  rawLinkVars["pageName"] = state
  _adb_buildAndSendRequest(data, rawLinkVars, CreateObject("roDateTime").AsSeconds())
End Function

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
Function _adb_worker() as Object
  if GetGlobalAA()._adb_worker = invalid
    instance = {
      queue: Function(fragment as String, timestamp as Integer) as Void
              if ADBMobile().getPrivacyStatus() = ADBMobile().PRIVACY_STATUS_OPT_IN
                newHit = {frag: fragment, stamp: timestamp}
                _adb_logger().debug("Analytics - Queued Hit (" + fragment + ")")
                m._queue.Push(newHit)
                m._sendNextHit()
              endif
            End Function,
      processMessage: Function() As Void
              ''' process this message if it's something we need to handle
              msg = wait(1, m._port)
              if type(msg) = "roUrlEvent" AND msg.GetSourceIdentity() = m._http.GetIdentity()
                responseCode = msg.GetResponseCode()
                if responseCode = 200
                  _adb_logger().debug("Analytics - Successfully sent hit (" + m._currentHit.frag + ")")
                  ''' parse response
                  responseString = msg.GetString()
                  responseObject = invalid
                  if responseString <> invalid AND Len(responseString.Trim()) > 0
                    responseObject = ParseJson(responseString)
                  endif
                  ''' if we have a audience response
                  if responseObject <> invalid
                    _adb_logger().debug("Analytics - JSON response received: " + responseString)
                    _adb_audienceManager()._processJsonResponse(responseObject)
                  else
                    _adb_logger().debug("Analytics - Empty or non JSON response received")
                  endif
                  
                else
                  _adb_logger().error("Analytics - Unable to send hit (" + msg.GetFailureReason() + ")")
                endif
                m._currentHit = invalid
                m._sendNextHit()
              endif
            End Function,
      _init: Function() as Void
              ''' create reusable instance vars
              m["_http"] = CreateObject("roUrlTransfer")
              m["_port"] = CreateObject("roMessagePort")
              m["_queue"] = []
              m["_currentHit"] = invalid
              ''' configure
              m._http.SetRequest("POST")
              m._http.SetMessagePort(m._port)
              m._http.SetCertificatesFile("common:/certs/ca-bundle.crt")
            End Function,
      _sendNextHit: Function() as Void
              if _adb_config().analyticsEnabled() = false
                _adb_logger().error("Analytics - Unable to send hit (Analytics not enabled in config file)")
                return
              end if
              if m._queue.count() > 0 AND m._currentHit = invalid
                ''' grab oldest hit in the queue
                m._currentHit = m._queue.Shift()
                ''' if offline is disabled we need to throw away hits older than 60 seconds
                if _adb_config().offlineTrackingEnabled = false
                  currentTime = CreateObject("roDateTime").AsSeconds()
                  delta = currentTime - m._currentHit.stamp
                  ''' hit is old, toss it.
                  if(delta > 60)
                    ''' invalidate current hit
                    m._currentHit = invalid
                    ''' recurse
                    m._sendNextHit()
                    return
                  endif
                endif
                ''' set url
                m._http.SetUrl(m._urlStub())
                ''' send it asynchronously
                m._http.AsyncPostFromString(m._currentHit.frag)
              end if
            End Function,
        _urlStub: Function() as String
              urlBase = ""
              if _adb_config().ssl
                urlBase = "https"
              else
                urlBase = "http"
              endif
              urlBase = urlBase + "://" + _adb_config().trackingServer + "/b/ss/" + _adb_config().reportSuiteIDs + "/" + _adb_config().getAnalyticsResponseType().ToStr() + "/BS-" + ADBMobile().version + "/s" + Rnd(1000000).ToStr()
              return urlBase
            End Function
        _clearHits: Function() as Void
            m._queue.Clear()
        End Function
    }
    instance._init()
    GetGlobalAA()["_adb_worker"] = instance
  endif
  return GetGlobalAA()._adb_worker
End Function

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
Function _adb_audienceManager() As Object
  if GetGlobalAA()._audienceManager = invalid
      instance = {
        _sanitizeRegex: CreateObject("roRegex", "\.", "i"),
        _fixRequestRegex: CreateObject("roRegex", "\?\&", "i"),
        submitSignal: Function(data As Object) As Void
            if ADBMobile().getPrivacyStatus() = ADBMobile().PRIVACY_STATUS_OPT_IN
              m._queue.Push(data)
              m._sendNextSignal()
            endif
          End Function,
        ''' processes messages received on the queue
        processMessage: Function() As Void
            ''' process this message if it's something we need to handle
            msg = wait(1, m._port)
            if type(msg) = "roUrlEvent" AND msg.GetSourceIdentity() = m._http.GetIdentity()
              responseCode = msg.GetResponseCode()
              ''' success
              if responseCode = 200
                _adb_logger().debug("Audience Manager - Successfully sent signal")
                ''' parse response
                responseString = msg.GetString()
                responseObject = invalid
                if responseString <> invalid AND Len(responseString) > 0
                  responseObject = ParseJson(responseString)
                endif
                ''' if we have a response
                if responseObject <> invalid
                  m._processJsonResponse(responseObject)
                  
                ''' handle non 200 response code
                else
                  _adb_logger().debug("Audience Manager - Empty or non JSON response received")
                endif
              else
                _adb_logger().error("Audience Manager - Unable to send signal (" + msg.GetFailureReason() + ")")
              endif
              m._currentHit = invalid
              m._sendNextSignal()
            endif
          End Function,
        ''' returns the current visitor profile as an associative array
        getVisitorProfile: Function() As Object
            visitorProfileString = _adb_persistenceLayer().readValue("aam_profile")
            if visitorProfileString <> invalid
              jsonObject = ParseJson(visitorProfileString)
              if jsonObject <> invalid
                return jsonObject
              endif
            endif
            return {}
          End Function,
        ''' sets current dpid/dpuuid
        setDpidAndDpuuid: Function(dpid as String, dpuuid as String) As Void
        '''handle clearing of _dpid/_dpuuid, should do this regardless of privacy setting
          if ADBMobile().getPrivacyStatus() <> ADBMobile().PRIVACY_STATUS_OPT_OUT
            m["_dpid"] = dpid
            m["_dpuuid"] = dpuuid
          endif
          
          End Function,
        ''' gets the currently set d_dpid
        getDpid: Function() As Dynamic
            return m._dpid
          End Function,
        ''' gets the currently set d_dpuuid
        getDpuuid: Function() As Dynamic
            return m._dpuuid
          End Function,
        _init: Function() As Void
            ''' initialize shared objects
            m["_queue"] = []
            m["_currentHit"] = invalid
            m["_http"] = CreateObject("roUrlTransfer")
            m["_port"] = CreateObject("roMessagePort")
            m["_uuid"] = m._getUUID()
            ''' configure
            m._http.SetRequest("GET")
            m._http.SetMessagePort(m._port)
            m._http.SetCertificatesFile("common:/certs/ca-bundle.crt")
          End Function,
        ''' sends the next signal waiting in the queue to AAM (async)
        _sendNextSignal: Function() As Void
            if _adb_config().aamServer <> invalid AND m._queue.count() > 0 AND m._currentHit = invalid
              ''' grab oldest hit in the queue
              m.["_currentHit"] = m._queue.Shift()
              ''' set url
              url = m._buildSchemaRequest(m._currentHit)
              m._http.SetUrl(url)
              _adb_logger().debug("Audience Manager - Sending signal request (" + url + ")")
              ''' send it asynchronously
              if m._http.AsyncGetToString() = false
                _adb_logger().error("Audience Manager - Unable to execute GET request to URL (" + url + ")")
              endif
            endif
          End Function,
        _processJsonResponse: Function(responseObject as Object) As Void
            ''' handle uuid
            if responseObject.uuid <> invalid
              m._setUUID(responseObject.uuid)
            endif
            ''' handle destinations
            dests = responseObject.dests
            if dests <> invalid
              for each destination in dests
                url = destination.c
                if url <> invalid
                  _adb_logger().debug("Audience Manager - Forwarding 'dests' request (" + url + ")")
                  urlTransfer = CreateObject("roUrlTransfer")
                  urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
                  urlTransfer.SetUrl(url)
                  urlTransfer.AsyncGetToString()
                endif
              end for
            endif
            ''' handle 'stuff'
            stuff = responseObject.stuff
            if stuff <> invalid
              newStuff = {}
              for each item in stuff
                if item.cn <> invalid
                  newStuff[item.cn] = item.cv
                endif
              end for
              ''' persist stuff
              _adb_persistenceLayer().writeValue("aam_profile", FormatJson(newStuff))
              _adb_logger().debug("Audience Manager - Updated Visitor Profile")
            endif
          End Function,
        _setVisitorProfile: Function(segments as Object) As Void
          End Function,
        _buildSchemaRequest: Function(data as Object) As String
            urlString = m._generateURLPrefix() + m._getCustomURLVariables(data) + m._getDataProviderURLVariables() + "&d_ptfm=roku&d_dst=1&d_rtbd=json"
            return m._fixRequestRegex.ReplaceAll(urlString, "?")
          End Function,
        _generateURLPrefix: Function() As String
            urlBase = ""
            if _adb_config().ssl
              urlBase = "https"
            else
              urlBase = "http"
            endif
            urlBase = urlBase + "://" + _adb_config().aamServer + "/event?"
            return urlBase
          End Function,
        _getCustomURLVariables: Function(data as Object) As String
            response = ""
            for each key in data
              response = response + _adb_urlEncoder()._serializeKeyValuePair(m._sanitize(key), data[key])
            end for
            return response
          End Function,
        _getDataProviderURLVariables: Function() As String
            response = ""
            if m._uuid <> invalid AND Len(m._uuid) > 0
              response = response + _adb_urlEncoder()._serializeKeyValuePair("d_uuid", m._uuid)
            endif
            response = response + _adb_visitor().aamParameters()
            if m._dpuuid <> invalid AND m._dpid <> invalid
              response = response + "&d_dpid=" + m._dpid + "&d_dpuuid=" + m._dpuuid
            endif
            return response
          End Function,
        ''' sanitizes a key for aam consumption.  This is to move context dat akeys over to aam parameters
        ''' where we need to change '.' delimiters to '_'
        _sanitize: Function(key as String) As String
            return m._sanitizeRegex.ReplaceAll(key, "_")
          End Function,
        ''' sets UUID to persistent storage
        _setUUID: Function(uuid as Dynamic) As Void
            if uuid <> invalid
              if ADBMobile().getPrivacyStatus() <> ADBMobile().PRIVACY_STATUS_OPT_OUT or uuid.Len() = 0
                _adb_persistenceLayer().writeValue("aam_uuid", uuid)
                m.["_uuid"] = uuid
              endif
            endif
          End Function,
        ''' returns the UUID for the AAM user
        _getUUID: Function() As Dynamic
            return _adb_persistenceLayer().readValue("aam_uuid")
          End Function,
        _resetData: Function() As Void
          _adb_persistenceLayer().removeValue("aam_uuid")
          m["_uuid"] = invalid
        End Function,
        _purgeDpidAndDpuuid: Function() As Void
            m["_dpid"] = invalid
            m["_dpuuid"] = invalid
        End Function,
        _clearHits: Function() as Void
            m._queue.Clear()
        End Function
    }
    instance._init()
    GetGlobalAA()["_audienceManager"] = instance
  endif
  return GetGlobalAA()._audienceManager
End Function

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
Function _adb_serializeAndSendHeartbeat() As Object
  if GetGlobalAA()._serializeAndSendHeartbeat = invalid
    instance = {
      _sanitizePublisherRegex: CreateObject("roRegex", "[^a-zA-Z0-9]+", "i"),
      queueRequestsForResponse: Function(data As Object) As Void
          '''vhl does not even queue hits if the status is not opt in (no offline tracking support yet)
          if ADBMobile().getPrivacyStatus() = ADBMobile().PRIVACY_STATUS_OPT_IN
            m._logger.debug("Queued Hit")
            m._queue.Push(data)
            m._sendNextHit()
          endif
        End Function,
      reset: Function() As Void
        m.flushAsyncRequests()
        m._init()
      End Function,
      flushAsyncRequests: Function() As Void
          while true
            ''' video complete will close video screen and stop processMessage.
            ''' keep this alive until all hits are sent
            m.processMessage()
            if m._currentHit <> invalid
              if _adb_clockservice().isActive() = true AND _adb_clockservice().timerTicked(_adb_clockservice().id_flushfilter_timer)
                ''' timeout the request if no response received within 250 ms
                m.timeOutActiveRequest()
                m._sendNextHit()
              endif
            endif
            ''' break the while loop when nothing is left to process in the queue
            if m._queue.count() = 0 AND m._currentHit = invalid
              exit while
            endif
          end while
        End Function,
      processMessage: Function() As Void
        ''' process this message if it's something we need to handle
        msg = wait(1, m._port)
        if type(msg) = "roUrlEvent" AND msg.GetSourceIdentity() = m._http.GetIdentity()
          m._currentHit = invalid
          m._urlRetry = false
          responseCode = msg.GetResponseCode()
            if responseCode = 200
              m._logger.debug("#processMessage() - Successfully sent status hit")
              ''' parse response
              responseXML = msg.GetString()
              setupData = invalid
              if responseXML <> invalid AND Len(responseXML) > 0
                setupData = CreateObject("roXMLElement")
                if not setupData.Parse(responseXML) then
                  m._logger.debug("#processMessage() - XML response could not be parsed (" + responseXML + ")")
                endif
              endif
              ''' if we have a response
              if setupData <> invalid
                responseConfig = {}
                m._logger.debug("#processMessage() - XML response (" + responseXML + ")")
                if setupData.trackingInterval <> invalid
                  responseConfig.trackingInterval = setupData.trackingInterval.GetText().ToInt()
                endif
                if setupData.trackExternalErrors <> invalid
                  responseConfig.trackExternalErrors = setupData.trackExternalErrors.GetText().ToInt()
                endif
                 if setupData.setupCheckInterval <> invalid
                  responseConfig.setupCheckInterval = setupData.setupCheckInterval.GetText().ToInt()
                endif
                if setupData.trackingDisabled <> invalid
                  if setupData.trackingDisabled.GetText().ToInt() = 1
                    responseConfig.trackingDisabled = true
                  endif
                endif
                ''' update the check status timer settings
                _adb_clockservice().updateCheckStatusInterval(responseConfig)
                ''' handle empty or invalid response
              else
                m._logger.debug("#processMessage() - Empty or invalid XML response received")
              endif
            ''' handle non 200 response code, 204 is received for heartbeat calls
            else if responseCode = 204
              m._logger.debug("#processMessage() - Successfully sent heartbeat hit")
            else
              m._logger.error("#processMessage() - Unable to send hit, Failure Reason: " + msg.GetFailureReason() + " ResponseCode: " + msg.GetResponseCode().ToStr())
            endif
            m._sendNextHit()
          endif
        End Function,
      timeOutActiveRequest: Function() As Void
          if m._currentHit <> invalid
            msg = wait(1, m._port)
            if msg = invalid AND m._urlRetry = false
              url = m._http.GetUrl()
              if url <> invalid
                m._http.AsyncCancel()
                ''' retry the URL one more time
                m._sendUrlRequest(true, url)
              endif
            else if msg = invalid AND m._urlRetry = true
              m._logger.error("#timeOutActiveRequest() - URL dropped after retry (" + m._http.GetUrl() + ")")
              m._http.AsyncCancel()
              m._currentHit = invalid
              m._urlRetry = false
            else if msg <> invalid
              ''' we have a response available so do nothing, ProcessMessage loop will handle this scenario
              m._currentHit = invalid
              m._urlRetry = false
            endif
          endif
           m._currentHit=invalid
        End Function,
      asyncStatusRequest: Function() As Void
          dictionary = {
            r: _adb_util().getTimestampInMillis()
          }
          m.queueRequestsForResponse(dictionary)
        End Function,
      _sendNextHit: Function() As Void
          if m._queue.count() > 0 AND m._currentHit = invalid
            ''' grab oldest hit in the queue
            m["_currentHit"] = m._queue.Shift()
            ''' set url and send it asynchronously
            url = m._buildHeartbeatUrl(m._currentHit)
            m._sendUrlRequest(false, url)
          endif
        End Function,
      _sendUrlRequest: Function(retryFlag as Boolean, url as String) As Void
          retry = ""
          if (retryFlag)
            retry = "Retry: "
          endif
          m._http = m._createMediaHeartbeatNetworkRequestObject()  ''' create a roUrlTransfer Object for every request
          if(m._http <> invalid)
            m._http.SetUrl(url)
            if (m._http.AsyncGetToString())
              m._logger.debug(retry + "#_sendUrlRequest() - Successfully sent Media Heartbeat Hit (" + url + ")")
              if _adb_clockservice().isActive() = true
                _flushFilterTimer = _adb_clockservice().getTimerHandle(_adb_clockservice().id_flushfilter_timer)
                _flushFilterTimer.reset()
              endif
              m._urlRetry = retryFlag
            else
              m._logger.error(retry + "#_sendUrlRequest() - Unable to execute GET request for URL (" + url + ")")
              m._http.AsyncCancel()
              m._currentHit = invalid
            endif
            else
              m._logger.error(retry + "#_sendUrlRequest() - Unable to make MediaHeartbeatRequest (request object null/invalid)")
          endif
        End Function,
      _buildHeartbeatUrl: Function(data as Object) As String
         checkStatus = false
         ''' check if Hit is for check status, if yes form a different Base URL
         if data.r <> invalid
          checkStatus = true
         endif
        serializedParameters = _adb_urlEncoder().serializeParameters(data)
        ''' trim the extra '&' sign at the beginning of query string
        if serializedParameters.Len() > 2
          serializedParameters = serializedParameters.Mid(1)
        endif
        urlString = m._generateURLPrefix(checkStatus) + serializedParameters
        return urlString
      End Function,
      _generateURLPrefix: Function(checkStatus as Boolean) As String
          urlBase = ""
          ''' assuming the media SSSL mediaTrackingServer parameters for now.
          if _adb_config().mTrackingServer <> INVALID
            if _adb_config().mSSL
              urlBase = "https"
            else
              urlBase = "http"
            endif
            urlBase = urlBase + "://" + _adb_config().mTrackingServer
            if (checkStatus)
              sanitizedPublisher = m._sanitizePublisherRegex.ReplaceAll(_adb_config().mPublisher, "-")
              urlBase = urlBase + "/settings/" + sanitizedPublisher + ".xml"
            endif
            urlBase = urlBase + "?"
          endif
          return urlBase
        End Function,
        _clearHits: Function() as Void
            m._queue.Clear()
        End Function,
      _init: Function() As Void
          ''' initialize shared objects
          m["_queue"] = []
          m["_currentHit"] = invalid
          m["_urlRetry"] = false
          m["_logger"] = _adb_logger().instanceWithTag("media/networkService")
          m._port = CreateObject("roMessagePort")
          ''' we need _logger instance and _port initialized before creating MediaHeartbeat request
          m._http = m._createMediaHeartbeatNetworkRequestObject()
        End Function
        _createMediaHeartbeatNetworkRequestObject: Function() As Object
          m._logger.debug("#_createMediaHeartbeatNetworkRequestObject() - Creating new MediaHeartbeat request")
          httpRequest = CreateObject("roUrlTransfer")
          httpRequest.SetRequest("GET")
          httpRequest.SetCertificatesFile("common:/certs/ca-bundle.crt")
          httpRequest.SetMessagePort(m._port)
          return httpRequest
        End Function
    }
    instance._init()
    GetGlobalAA()["_serializeAndSendHeartbeat"] = instance
  endif
  return GetGlobalAA()._serializeAndSendHeartbeat
End Function

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
Function _adb_clockservice() As Object
  if GetGlobalAA()._adb_clockservice = invalid
    instance = {
      updateCheckStatusInterval: Function(setupData as Object) as void
          if setupData.setupCheckInterval <> invalid
            valType = type(setupData.setupCheckInterval)
            if valType = "roInteger" OR valType = "roInt" OR valType = "Integer"
              m._logger.debug("Updating the check status interval to: " + setupData.setupCheckInterval.ToStr())
              m.restartTimerWithNewInterval(m.id_checkstatus_timer, setupData.setupCheckInterval * 1000, true)
            else
              m._logger.debug("UpdateCheckStatusInterval: interval not an Integer")
            endif
          else
            m._logger.debug("UpdateCheckStatusInterval: setupCheckInterval is invalid")
          endif
          if setupData.trackingDisabled <> invalid AND setupData.trackingDisabled = true
            _adb_media()._disableMedia()
          endif
        End Function,
      restartTimerWithNewInterval: Function(timerName as String, newInterval as Integer, updateDefaultInterval = false as Boolean) as Object
          timer = m._timers[timerName]
          if timer <> invalid
            timer.timerHandle.restartWithNewInterval(newInterval)
            if updateDefaultInterval
              timer.defaultInterval = newInterval
            end if
          end if
      End Function
      timerTicked: Function(timerName as String) As Boolean
          timerHandle = m.getTimerHandle(timerName)
          if timerHandle <> invalid AND timerHandle.enabled() AND timerHandle.ticked()
            return true
          end if
          return false
      End Function,
      startClockService: Function() As Void
          for each timerName in m._timers
            timer = m._timers[timerName]
            if timer.autoStart
              m.startTimer(timerName)
            end if
          end for
          m._active = true
        End Function,
      stopClockService: Function() As Void
          if m.isActive()
            for each timerName in m._timers
              m.stopTimer(timerName)
            end for
            m._active = false
          end if
        End Function,
      isActive: Function() As Boolean
          return m._active
        End Function,
      getTimerHandle: Function(timerName as String) as Dynamic
          timer = m._timers[timerName]
          if timer <> invalid
            return timer.timerHandle
          end if
          return invalid
        End Function
      startTimer: Function(timerName as String) as Void
        timer = m._timers[timerName]
        if timer <> invalid
          timer.timerHandle.start(timer.defaultInterval, timerName)
        end if
      End Function
      stopTimer: Function(timerName as String) as Void
        timer = m._timers[timerName]
        if timer <> invalid
          timer.timerHandle.stop()
        end if
      End Function
      _addTimer: Function(timerName as String, defaultInterval as Integer, autoStart as Boolean) as Object
          m._timers[timerName] = {
            timerHandle :  _adb_timer(), 
            defaultInterval: defaultInterval,
            autoStart : autoStart
          }
      End Function
      _init: Function() As Void
          m.id_reporting_timer   = "ReportingTimer"
          m.id_checkstatus_timer = "CheckStatusTimer"
          m.id_flushfilter_timer = "FlushFilterTimer"
          m.id_playhead_timer    = "PlayheadTimer"
          m._logger = _adb_logger().instanceWithTag("media/ClockService")
          m._active = false
          m._timers = {}
          m._addTimer(m.id_reporting_timer, 10000, true)
          m._addTimer(m.id_checkstatus_timer, 180000, true)
          m._addTimer(m.id_flushfilter_timer, 3000, true)
          m._addTimer(m.id_playhead_timer, 1000, false)
      End Function
    }
    instance._init()
    GetGlobalAA()["_adb_clockservice"] = instance
  endif
  return GetGlobalAA()._adb_clockservice
End Function
Function _adb_clockservice_loop() As Void
    clockservice = _adb_clockservice()
    if clockservice.isActive()
      for each timerName in clockservice._timers
        if clockservice.timerTicked(timerName)
          _adb_media().clockServiceCallback(timerName)
        end if
      end for
    end if
End Function

' *************************************************************************
' *
' * ADOBE CONFIDENTIAL
' * ___________________
' *
' *  Copyright 2018 Adobe Systems Incorporated
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
Function _adb_media_loadconstants(instance as Object)
  _adb_media_loadEventConstants(instance)
  _adb_media_loadMediaKeyConstants(instance)
  _adb_media_loadStandardMetadataConstants(instance)
End Function
Function _adb_media_loadMediaKeyConstants(instance as Object)
  instance.MEDIA_TYPE_AUDIO      = "audio"
  instance.MEDIA_TYPE_VIDEO      = "video"
  instance.MEDIA_STREAM_TYPE_VOD          = "vod"
  instance.MEDIA_STREAM_TYPE_LIVE         = "live"
  instance.MEDIA_STREAM_TYPE_LINEAR       = "linear"
  instance.MEDIA_STREAM_TYPE_PODCAST      = "podcast"
  instance.MEDIA_STREAM_TYPE_AUDIOBOOK    = "audiobook"
  instance.MEDIA_STREAM_TYPE_AOD          = "aod"
  instance.ERROR_SOURCE_PLAYER            = "sourceErrorSDK"
  instance.MEDIA_RESUMED                  = "resumed"
  instance.PREROLL_TRACKING_WAITING_TIME  = "prerolltrackingwaitingtime"
  instance.MEDIA_STANDARD_MEDIA_METADATA  = "media_standard_content_metadata"
  instance.MEDIA_STANDARD_AD_METADATA     = "media_standard_ad_metadata"
  '@Deprecated
  instance.MEDIA_STANDARD_VIDEO_METADATA  = "media_standard_content_metadata"
  instance.VIDEO_RESUMED                  = "resumed"
End Function
Function _adb_media_loadEventConstants(instance as Object)
  instance.MEDIA_AD_BREAK_START           = "MediaAdBreakStart"
  instance.MEDIA_AD_BREAK_COMPLETE        = "MediaAdBreakComplete"
  instance.MEDIA_AD_BREAK_SKIP            = "MediaAdBreakSkip"
  instance.MEDIA_AD_START                 = "MediaAdStart"
  instance.MEDIA_AD_COMPLETE              = "MediaAdComplete"
  instance.MEDIA_AD_SKIP                  = "MediaAdSkip"
  instance.MEDIA_CHAPTER_START            = "MediaChapterStart"
  instance.MEDIA_CHAPTER_COMPLETE         = "MediaChapterComplete"
  instance.MEDIA_CHAPTER_SKIP             = "MediaChapterSkip"
  instance.MEDIA_BUFFER_START             = "MediaBufferStart"
  instance.MEDIA_BUFFER_COMPLETE          = "MediaBufferComplete"
  instance.MEDIA_SEEK_START               = "MediaSeekStart"
  instance.MEDIA_SEEK_COMPLETE            = "MediaSeekComplete"
  instance.MEDIA_BITRATE_CHANGE           = "MediaBitrateChange"
End Function
Function _adb_media_loadStandardMetadataConstants(instance as Object)
  ' Standard Video metadata keys
  instance.MEDIA_VideoMetadataKeySHOW                    = "a.media.show"
  instance.MEDIA_VideoMetadataKeySEASON                  = "a.media.season"
  instance.MEDIA_VideoMetadataKeyEPISODE                 = "a.media.episode"
  instance.MEDIA_VideoMetadataKeyASSET_ID                = "a.media.asset"
  instance.MEDIA_VideoMetadataKeyGENRE                   = "a.media.genre"
  instance.MEDIA_VideoMetadataKeyFIRST_AIR_DATE          = "a.media.airDate"
  instance.MEDIA_VideoMetadataKeyFIRST_DIGITAL_DATE      = "a.media.digitalDate"
  instance.MEDIA_VideoMetadataKeyRATING                  = "a.media.rating"
  instance.MEDIA_VideoMetadataKeyORIGINATOR              = "a.media.originator"
  instance.MEDIA_VideoMetadataKeyNETWORK                 = "a.media.network"
  instance.MEDIA_VideoMetadataKeySHOW_TYPE               = "a.media.type"
  instance.MEDIA_VideoMetadataKeyAD_LOAD                 = "a.media.adLoad"
  instance.MEDIA_VideoMetadataKeyMVPD                    = "a.media.pass.mvpd"
  instance.MEDIA_VideoMetadataKeyAUTHORIZED              = "a.media.pass.auth"
  instance.MEDIA_VideoMetadataKeyDAY_PART                = "a.media.dayPart"
  instance.MEDIA_VideoMetadataKeyFEED                    = "a.media.feed"
  instance.MEDIA_VideoMetadataKeySTREAM_FORMAT           = "a.media.format"
  ' Standard Audio metadata keys
  instance.MEDIA_AudioMetadataKeyARTIST                  = "a.media.artist"
  instance.MEDIA_AudioMetadataKeyALBUM                   = "a.media.album"
  instance.MEDIA_AudioMetadataKeyLABEL                   = "a.media.label"
  instance.MEDIA_AudioMetadataKeyAUTHOR                  = "a.media.author"
  instance.MEDIA_AudioMetadataKeySTATION                 = "a.media.station"
  instance.MEDIA_AudioMetadataKeyPUBLISHER               = "a.media.publisher"
  ' Standard Ad metadata keys
  instance.MEDIA_AdMetadataKeyADVERTISER                 = "a.media.ad.advertiser"
  instance.MEDIA_AdMetadataKeyCAMPAIGN_ID                = "a.media.ad.campaign"
  instance.MEDIA_AdMetadataKeyCREATIVE_ID                = "a.media.ad.creative"
  instance.MEDIA_AdMetadataKeyPLACEMENT_ID               = "a.media.ad.placement"
  instance.MEDIA_AdMetadataKeySITE_ID                    = "a.media.ad.site"
  instance.MEDIA_AdMetadataKeyCREATIVE_URL               = "a.media.ad.creativeURL"
End Function

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
Function _adb_media() As Object
  if GetGlobalAA()._adb_media_instance = invalid
      instance = {
        _init: Function() As Void
          'Initialize sub components.
          _adb_serializeAndSendHeartbeat()
          _adb_clockservice()
          _adb_mediacontext()
          _adb_paramsResolver()
          m._setConstants()
          m._isEnabled = true
          m._logger = _adb_logger().instanceWithTag("media/media")
          m._ruleEngine = _adb_ruleengine()
          m._setupRules()
          m._resetTrackingState()
        End Function,
' **************************************************************************
' Public Methods
' **************************************************************************
        trackSessionStart: Function(mediaInfo as Object, contextData = invalid as Object) As Void
          m._logger.debug("#::trackSessionStart()")
          reContext = m._ruleEngine.createContext()
          reContext.setData(m._KEY_MEDIA_OBJECT, mediaInfo)
          reContext.setData(m._KEY_CUSTOM_METADATA, m._cleanContextData(contextData))
          m._processRule(m._Rule.SessionStart, reContext)
        End Function,
        trackSessionEnd: Function() As Void
          m._logger.debug("#::trackSessionEnd()")
          m._processRule(m._Rule.SessionEnd)
        End Function,
        trackPlay: Function() As Void
          m._logger.debug("#::trackPlay()")
          m._processRule(m._Rule.Play)
        End Function,
        trackPause: Function() As Void
          m._logger.debug("#::trackPause()")
          m._processRule(m._Rule.Pause)
        End Function,
        trackComplete: Function() As Void
          m._logger.debug("#::trackComplete()")
          m._processRule(m._Rule.VideoComplete)
        End Function,
        trackError: Function(errorId As String, errorSource As String) As Void
            m._logger.debug("#::trackError()")
            reContext = m._ruleEngine.createContext()
            reContext.setData(m._KEY_ERROR_ID, errorId)
            reContext.setData(m._KEY_ERROR_SOURCE, errorSource)
            m._processRule(m._Rule.Error, reContext)
        End Function,
        trackMediaEvent: Function(event as String, info = invalid as Object, contextData = invalid as Object) As Void
            m._logger.debug("#::trackEvent(" + event + ")")
            ruleName = ""
            reContext = m._ruleEngine.createContext()
            if (event = ADBMobile().MEDIA_AD_BREAK_START)
              reContext.setData(m._KEY_ADBREAK_OBJECT, info)
              reContext.setData(m._KEY_CUSTOM_METADATA, m._cleanContextData(contextData))
              ruleName = m._Rule.AdBreakStart
            else if (event = ADBMobile().MEDIA_AD_BREAK_COMPLETE)
              ruleName = m._Rule.AdBreakComplete
            else if (event = ADBMobile().MEDIA_AD_BREAK_SKIP)
              'Currently there is not a big difference between AdBreakComplete and AdBreakSkip
              ruleName = m._Rule.AdBreakComplete
            else if (event = ADBMobile().MEDIA_AD_START)
              reContext.setData(m._KEY_AD_OBJECT, info)
              reContext.setData(m._KEY_CUSTOM_METADATA, m._cleanContextData(contextData))
              ruleName = m._Rule.AdStart
            else if (event = ADBMobile().MEDIA_AD_COMPLETE)
              ruleName = m._Rule.AdComplete
            else if (event = ADBMobile().MEDIA_AD_SKIP)
              ruleName = m._Rule.AdSkip
            else if (event = ADBMobile().MEDIA_CHAPTER_START)
              reContext.setData(m._KEY_CHAPTER_OBJECT, info)
              reContext.setData(m._KEY_CUSTOM_METADATA, m._cleanContextData(contextData))
              ruleName = m._Rule.ChapterStart
            else if (event = ADBMobile().MEDIA_CHAPTER_COMPLETE)
              ruleName = m._Rule.ChapterComplete
            else if (event = ADBMobile().MEDIA_CHAPTER_SKIP)
              ruleName = m._Rule.ChapterSkip
            else if (event = ADBMobile().MEDIA_BUFFER_START)
              ruleName = m._Rule.BufferStart
            else if (event = ADBMobile().MEDIA_BUFFER_COMPLETE)
              ruleName = m._Rule.BufferComplete
            else if (event = ADBMobile().MEDIA_SEEK_START)
              ruleName = m._Rule.SeekStart
            else if (event = ADBMobile().MEDIA_SEEK_COMPLETE)
              ruleName = m._Rule.SeekComplete
            else if (event = ADBMobile().MEDIA_BITRATE_CHANGE)
              ruleName = m._Rule.BitrateChange
            else
              m._logger.error("#::trackEvent() - Unsupported event.")
              return
            end if
            m._processRule(ruleName, reContext)
        End Function,
        updatePlayhead: Function(postion as Integer) As Void
          'm._logger.debug("#::updatePlayhead()")
          reContext = m._ruleEngine.createContext()
          reContext.setData(m._KEY_PLAYHEAD, postion)
          m._processRule(m._Rule.PlayheadUpdate, reContext)
        End Function,
        updateQoSData: Function(qosInfo as Object) As Void
          'm._logger.debug("#::updateQoSData()")
          reContext = m._ruleEngine.createContext()
          reContext.setData(m._KEY_QOS_OBJECT, qosInfo)
          m._processRule(m._Rule.QosUpdate, reContext)
        End Function,
' **************************************************************************
' Deprecated Methods
' **************************************************************************
        trackLoad: Function(mediaInfo as Object, contextData as Object) As Void
          m._logger.debug("[Deprecated] #trackLoad()")
          m._trackLoadInfo = {
            mediaInfo : mediaInfo,
            contextData : contextData
          }
        End Function,
        trackStart: Function() As Void
          m._logger.debug("[Deprecated] #trackStart()")
          if m._trackLoadInfo <> invalid
            m.trackSessionStart(m._trackLoadInfo.mediaInfo, m._trackLoadInfo.contextData)
          else
            m._logger.debug("[Deprecated] Call #trackLoad(mediaInfo, contextData) before #trackStart()")
          end if
        End Function,
        trackUnload: Function() As Void
          m._logger.debug("[Deprecated] #trackUnload()")
          m.trackSessionEnd()
        End Function,
' **************************************************************************
' Callbacks
' **************************************************************************
        clockServiceCallback: Function(timerName As String) As Void
          if timerName = _adb_clockservice().id_checkstatus_timer
            m._logger.debug("Timer Ticked - Status Timer")
            _adb_serializeAndSendHeartbeat().asyncStatusRequest()
          else if timerName = _adb_clockservice().id_flushfilter_timer
            ' Floods logging
            ' m._logger.debug("Timer Ticked - Flush Timer")
            _adb_serializeAndSendHeartbeat().timeOutActiveRequest()
          else if timerName = _adb_clockservice().id_reporting_timer
            m._logger.debug("Timer Ticked - Reporting Timer")
            m._reportingTimerFn()
          else if timerName = _adb_clockservice().id_playhead_timer
            ' Floods logging
            ' m._logger.debug("Timer Ticked - Playhead Timer")
            m._playheadTimerFn()
          end if
        End Function,
        _playheadTimerFn: Function() As Void
          currentPlayhead = _adb_mediacontext().getCurrentPlayhead()
          reContext = m._ruleEngine.createContext()
          reContext.setData(m._KEY_PLAYHEAD, currentPlayhead)
          m._cmdDetectContentStart(reContext)
          m._cmdDetectVideoStall(reContext)
        End Function,
        _reportingTimerFn: Function() As Void
          if m._isInMedia(invalid)
            m._cmdDetectVideoIdle(invalid)
            m._cmdTrackPlaybackState(invalid)
          end if
        End Function,
' **************************************************************************
' Rule Engine Methods
' **************************************************************************
        _isError: Function(reContext as Object) As Boolean
          return _adb_media_isInErrorState()
        End Function,
        _isMediaDisabled: Function(reContext = invalid as Object) As Boolean
          return NOT(m._isEnabled)
        End Function,
        _isTracking: Function(reContext as Object) As Boolean
          return _adb_mediacontext().isActiveTracking()
        End Function,
        _isInMedia: Function(reContext as Object) As Boolean
          return _adb_mediacontext().isActiveSession()
        End Function,
        _isInAd: Function(reContext as Object) As Boolean
          return _adb_mediacontext().isInAd()
        End Function,
        _isInAdBreak: Function(reContext as Object) As Boolean
          return _adb_mediacontext().isInAdBreak()
        End Function,
        _isInChapter: Function(reContext as Object) As Boolean
          return _adb_mediacontext().isInChapter()
        End Function,
        _isInBuffer: Function(reContext as Object) As Boolean
          return _adb_mediacontext().isBuffering()
        End Function,
        _isInSeek: Function(reContext as Object) As Boolean
          return _adb_mediacontext().isSeeking()
        End Function,
        _isValidMediaObject: Function(reContext as Object) As Boolean
          mediaObject = reContext.getData(m._KEY_MEDIA_OBJECT)
          if mediaObject <> invalid AND _adb_media_object().isValidMediaInfoObject(mediaObject)
            resumedVal = mediaObject[ADBMobile().MEDIA_RESUMED]
            if resumedVal <> invalid AND type(resumedVal) <> "roBoolean" AND type(resumedVal) <> "Boolean"
              m._logger.warning("Ignoring value set for ADBMobile().MEDIA_RESUMED in MediaObject as we expect a boolean value")
            end if
            prerollWaitTimeVal = mediaObject[ADBMobile().PREROLL_TRACKING_WAITING_TIME]
            if prerollWaitTimeVal <> invalid AND type(prerollWaitTimeVal) <> "roInt" AND type(prerollWaitTimeVal) <> "Integer"
              m._logger.warning("Ignoring value set for ADBMobile().PREROLL_TRACKING_WAITING_TIME in MediaObject as we expect a valid duration as integer in milliseconds.")
            end if
            standardMediaMetadataVal = mediaObject[ADBMobile().MEDIA_STANDARD_MEDIA_METADATA]
            if standardMediaMetadataVal <> invalid AND type(standardMediaMetadataVal) <> "roAssociativeArray"
              m._logger.warning("Ignoring value set for ADBMobile().MEDIA_STANDARD_MEDIA_METADATA in MediaObject as we expect a valid object with kv pairs.")
            end if
            return true
          end if
          return false
        End Function,
        _isValidAdBreakObject: Function(reContext as Object) As Boolean
          adBreakObject = reContext.getData(m._KEY_ADBREAK_OBJECT)
          return adBreakObject <> invalid AND _adb_media_object().isValidAdBreakInfoObject(adBreakObject)
        End Function,
        _isDifferentAdBreakObject: Function(reContext as Object) As Boolean
          adBreakObject = reContext.getData(m._KEY_ADBREAK_OBJECT)
          currentAdBreakObject = _adb_mediacontext().getAdBreakInfo()
          return currentAdBreakObject = invalid OR (NOT _adb_media_object().isSameAdBreakInfoObject(currentAdBreakObject, adBreakObject))
        End Function,
        _isValidAdObject: Function(reContext as Object) As Boolean
            adObject = reContext.getData(m._KEY_AD_OBJECT)
            if adObject <> invalid AND _adb_media_object().isValidAdInfoObject(adObject)
              granularTrackingVal = adObject[m._MediaObjectKey_GranularAdTracking]
              if granularTrackingVal <> invalid AND type(granularTrackingVal) <> "roBoolean" AND type(granularTrackingVal) <> "Boolean"
                m._logger.warning("Ignoring value set for ADBMobile().GRANULAR_AD_TRACKING in AdObject as we expect a boolean value.")
              end if
              standardAdMetadataVal = adObject[ADBMobile().MEDIA_STANDARD_AD_METADATA]
              if standardAdMetadataVal <> invalid AND type(standardAdMetadataVal) <> "roAssociativeArray"
                m._logger.warning("Ignoring value set for ADBMobile().MEDIA_STANDARD_AD_METADATA in AdObject as we expect a valid object with kv pairs.")
              end if
              return true
            end if
            return false
        End Function,
        _isDifferentAdObject: Function(reContext as Object) As Boolean
          adObject = reContext.getData(m._KEY_AD_OBJECT)
          currentAdObject = _adb_mediacontext().getAdInfo()
          return currentAdObject = invalid OR (NOT _adb_media_object().isSameAdInfoObject(currentAdObject, adObject))
        End Function,
        _isValidChapterObject: Function(reContext as Object) As Boolean
          chapterObject = reContext.getData(m._KEY_CHAPTER_OBJECT)
          return chapterObject <> invalid AND _adb_media_object().isValidChapterInfoObject(chapterObject)
        End Function,
        _isDifferentChapterObject: Function(reContext as Object) As Boolean
          chapterObject = reContext.getData(m._KEY_CHAPTER_OBJECT)
          currentChapterObject = _adb_mediacontext().getChapterInfo()
          return currentChapterObject = invalid OR (NOT _adb_media_object().isSameChapterInfoObject(currentChapterObject, chapterObject))
        End Function,
        _isValidQoSInfoObject : Function(reContext as Object) As Boolean
            qosObject = reContext.getData(m._KEY_QOS_OBJECT)
            return qosObject <> invalid AND _adb_media_object().isValidQoSInfoObject(qosObject)
        End Function,
        _deferredTrackPlay : Function() As Void
          if NOT m._prerollWaitEnabled
            return
          end if
          m._logger.debug("Executing deferred API:trackPlay.")
          m._prerollWaitEnabled = false
          m._playTaskHandle = invalid
          m._processRule(m._Rule.Play)
        End Function,
        _doAllowPlayerStateChange: Function(reContext as Object) As Boolean
          return Not (_adb_mediacontext().isInAdBreak() AND (NOT _adb_mediacontext().isInAd()))
        End Function,
        _forceSwitchToBuffering: Function() As Void
          _adb_mediacontext().forceStateToBuffering(true)
          _adb_mediacontext().resetAssetRefContext()
          m._logger.debug("#_forceSwitchToBuffering - Forcing into buffer State.")
        End Function,
        _restoreToPreviousState: Function() As Void
          _adb_mediacontext().forceStateToBuffering(false)
          _adb_mediacontext().resetAssetRefContext()
          m._logger.debug("#_restoreToPreviousState - Out of forced buffer State.")
        End Function,
        _cmdEnterAction: Function(reContext as Object) As Void
          ruleName = reContext.getRuleName()
          if m._prerollWaitEnabled
            if (NOT m._playReceived)
              if ruleName = m._Rule.Play
                m._logger.debug("Deferring API:trackPlay for" + Str(m._prerollWaitTime) + " ms.")
                m._playReceived = true
                m._playUnhandledFromPrerollWaitTime = true
                m._playTaskHandle = _adb_task_scheduler().scheduleTask("_deferredTrackPlay", m, m._prerollWaitTime)
                reContext.stopProcessingAction()
              else if ruleName = m._Rule.AdBreakStart
                m._logger.debug("Received trackEvent(AdBreakStart) before first trackPlay, disabling preroll logic.")
                m._prerollWaitEnabled = false
              end if
            else
                ' Now if we reach here. We have a scheduled task.
              if ruleName = m._Rule.SeekStart OR ruleName = m._Rule.BufferStart
                m._logger.debug("Cancelling scheduled API:trackPlay because of SeekStart/BufferStart event")
                _adb_task_scheduler().cancelTask(m._playTaskHandle)
                m._playTaskHandle = invalid
              else if ruleName = m._Rule.SeekComplete OR ruleName = m._Rule.BufferComplete
                m._logger.debug("Rescheduled API:trackPlay after SeekComplete/BufferComplete event")
                m._playTaskHandle = _adb_task_scheduler().scheduleTask("_deferredTrackPlay", m, m._prerollWaitTime)
              else if ruleName = m._Rule.Play
                m._logger.debug("Dropping API:trackPlay as we already have a API:trackPlay scheduled.")
                reContext.stopProcessingAction()
              else if ruleName = m._Rule.Pause
                m._logger.debug("Cancelling scheduled API:trackPlay because of API:trackPause call.")
                _adb_task_scheduler().cancelTask(m._playTaskHandle)
                m._playTaskHandle = invalid
                m._prerollWaitEnabled = false
              else if ruleName = m._Rule.AdBreakStart
                m._logger.debug("Received API:trackEvent(AdBreakStart) within" + Str(m._prerollWaitTime) + " ms after API:trackPlay. We will track this as preroll AdBreak.")
                _adb_task_scheduler().cancelTask(m._playTaskHandle)
                m._playTaskHandle = invalid
                m._prerollWaitEnabled = false
              end if
            end if
          end if
        End Function,
        _cmdExitAction: Function(reContext as Object) As Void
          ruleName = reContext.getRuleName()
          if ruleName = m._Rule.AdStart AND _adb_mediacontext().hasPlaybackStarted() = false
            m._processRule(m._Rule.Play)
          end if
          ''' This case happens when AdBreakStart and AdBreakComplete is called with out any Ads.
          ''' We dropped the trackPlay when waiting for preroll AdBreak
          ''' and we have to issue it when we did not get a chance to execute deferred trackPlay.
          if (NOT m._prerollWaitEnabled)  AND  m._playUnhandledFromPrerollWaitTime AND (ruleName = m._Rule.BufferComplete OR ruleName = m._Rule.SeekComplete OR ruleName = m._Rule.AdBreakComplete)
            if (NOT _adb_mediacontext().hasPlaybackStarted()) AND (NOT _adb_mediacontext().isBuffering()) AND (NOT _adb_mediacontext().isSeeking())
              m._logger.debug("#_cmdExitAction() - Executing pending API:trackPlay. This case most likely happens tracking Preroll AdBreak without any Ads.")
              m._processRule(m._Rule.Play)
            end if
          end if
        End Function,
        _cmdConfigure: Function(reContext as Object) As Void
          _adb_clockservice().startClockService()
          _adb_serializeAndSendHeartbeat().asyncStatusRequest()
        End Function,
        _cmdSessionStart: Function(reContext as Object) As Void
          mediaObject = reContext.getData(m._KEY_MEDIA_OBJECT)
          mediaMetadata = reContext.getData(m._KEY_CUSTOM_METADATA)
          if mediaMetadata = invalid
            mediaMetadata = {}
          end if
          standardMediaMetadata = mediaObject[ADBMobile().MEDIA_STANDARD_MEDIA_METADATA]
          if standardMediaMetadata <> invalid AND type(standardMediaMetadata) = "roAssociativeArray"
            mediaMetadata.append(m._cleanContextData(standardMediaMetadata))
          end if
          mediaMetadata[m._KEY_CONTEXTDATA_MEDIATYPE] = mediaObject.mediaType
          prerollWaitTime = mediaObject[ADBMobile().PREROLL_TRACKING_WAITING_TIME]
          if prerollWaitTime <> invalid AND (type(prerollWaitTime) = "roInt" OR type(prerollWaitTime) = "roInteger" OR type(prerollWaitTime) = "Integer")
            m._prerollWaitTime = prerollWaitTime
            if prerollWaitTime <= 0
              m._prerollWaitEnabled = false
            end if
          end if
          _adb_mediacontext().setMediaInfo(mediaObject)
          _adb_mediacontext().setMediaContextData(mediaMetadata)
          _adb_mediacontext().setIsActiveTracking(true)
          _adb_mediacontext().setIsActiveSession(true)
          m._trackInternal(_adb_paramsResolver()._media_start)
          ' Send resume ping if set in metadata.
          mediaResumed = mediaObject[ADBMobile().MEDIA_RESUMED]
          if mediaResumed <> invalid AND (type(mediaResumed) = "roBoolean" OR type(mediaResumed) = "Boolean") AND mediaResumed = true
            m._trackInternal(_adb_paramsResolver()._media_resume)
          end if
          _adb_mediacontext().resetAssetRefContext()
        End Function,
        _cmdHandleMediaComplete: Function(reContext as Object) As Void
          if NOT _adb_mediacontext().isActiveSession()
            m._logger.debug("API:trackComplete has already cleaned up Heartbeat instance.")
            m._cmdSessionEnd(reContext)
            reContext.stopProcessingAction()
          end if
        End Function,
        _cmdVideoEnd: Function(reContext as Object) As Void
          if _adb_mediacontext().isActiveSession()
            if reContext.getRuleName() = m._Rule.VideoComplete
              endEvent = _adb_paramsResolver()._media_complete
            else
              endEvent = _adb_paramsResolver()._media_end
            end if
            m._trackInternal(endEvent)
            _adb_mediacontext().setIsActiveSession(false)
          end if
        End Function,
        _cmdSessionEnd: Function(reContext as Object) As Void
          _adb_clockservice().stopClockService()
          _adb_serializeAndSendHeartbeat().reset()
          _adb_mediacontext().setIsActiveTracking(false)
          m._resetTrackingState()
        End Function,
        _cmdAdBreakStart: Function(reContext as Object) As Void
          adBreakObject = reContext.getData(m._KEY_ADBREAK_OBJECT)
          _adb_mediacontext().setAdBreakInfo(adBreakObject)
          m._forceSwitchToBuffering()
        End Function,
        _cmdAdBreakComplete: Function(reContext as Object) As Void
          _adb_mediacontext().setAdBreakInfo(invalid)
          m._restoreToPreviousState()
        End Function,
        _cmdAdStart: Function(reContext as Object) As Void
          'We force send main:buffer calls within AdBreak and outside Ad and we revert back the playback state before entering Ad.
          m._restoreToPreviousState()
          adObject = reContext.getData(m._KEY_AD_OBJECT)
          adMetadata = reContext.getData(m._KEY_CUSTOM_METADATA)
          if adMetadata = invalid
            adMetadata = {}
          end if
          standardAdMetadata = adObject[ADBMobile().MEDIA_STANDARD_AD_METADATA]
          if standardAdMetadata <> invalid AND type(standardAdMetadata) = "roAssociativeArray"
            adMetadata.append(m._cleanContextData(standardAdMetadata))
          end if
          _adb_mediacontext().setInAdTo(true)
          _adb_mediacontext().setAdInfo(adObject)
          _adb_mediacontext().setAdContextData(adMetadata)
          m._trackInternal(_adb_paramsResolver()._ad_start)
          _adb_mediacontext().resetAssetRefContext()
          granularAdTracking = true
          granularTrackingVal = adObject[m._MediaObjectKey_GranularAdTracking]
          if granularTrackingVal <> invalid AND (type(granularTrackingVal) = "roBoolean" OR type(granularTrackingVal) = "Boolean")
            granularAdTracking = granularTrackingVal
          end if
          if granularAdTracking
            _adb_clockservice().restartTimerWithNewInterval(_adb_clockservice().id_reporting_timer, m._DEFAULT_AD_TRACKING_INTERVAL)
          end if
        End Function,
        _cmdAdComplete: Function(reContext as Object) As Void
          m._trackInternal(_adb_paramsResolver()._ad_complete)
          _adb_mediacontext().setInAdTo(false)
          _adb_mediacontext().setAdInfo(invalid)
          _adb_mediacontext().setAdContextData(invalid)
          _adb_mediacontext().resetAssetRefContext()
          _adb_clockservice().restartTimerWithNewInterval(_adb_clockservice().id_reporting_timer, m._DEFAULT_CONTENT_TRACKING_INTERVAL)
          m._forceSwitchToBuffering()
        End Function,
        _cmdAdSkip: Function(reContext as Object) As Void
          if _adb_mediacontext().isInAd()
            _adb_mediacontext().setInAdTo(false)
            _adb_mediacontext().setAdInfo(invalid)
            _adb_mediacontext().setAdContextData(invalid)
            _adb_mediacontext().resetAssetRefContext()
            _adb_clockservice().restartTimerWithNewInterval(_adb_clockservice().id_reporting_timer, m._DEFAULT_CONTENT_TRACKING_INTERVAL)
            m._forceSwitchToBuffering()
          end if
        End Function,
        _cmdChapterStart: Function(reContext as Object) As Void
          chapterObject = reContext.getData(m._KEY_CHAPTER_OBJECT)
          chapterMetadata = reContext.getData(m._KEY_CUSTOM_METADATA)
          _adb_mediacontext().setInChapterTo(true)
          _adb_mediacontext().setChapterInfo(chapterObject)
          _adb_mediacontext().setChapterContextData(chapterMetadata)
          m._trackInternal(_adb_paramsResolver()._chapter_start)
          _adb_mediacontext().resetAssetRefContext()
          ' Force send a play event with duration 0, if content is playing
          if _adb_mediacontext().isPlaying()
            m._cmdTrackPlaybackState(reContext)
          end if
        End Function,
        _cmdChapterComplete: Function(reContext as Object) As Void
          m._trackInternal(_adb_paramsResolver()._chapter_complete)
          _adb_mediacontext().setInChapterTo(false)
          _adb_mediacontext().setChapterInfo(invalid)
          _adb_mediacontext().setChapterContextData(invalid)
          _adb_mediacontext().resetAssetRefContext()
        End Function,
        _cmdChapterSkip: Function(reContext as Object) As Void
          if _adb_mediacontext().isInChapter()
            _adb_mediacontext().setInChapterTo(false)
            _adb_mediacontext().setChapterInfo(invalid)
            _adb_mediacontext().setChapterContextData(invalid)
            _adb_mediacontext().resetAssetRefContext()
          end if
        End Function,
        _cmdPlay: Function(reContext as Object) As Void
          _adb_mediacontext().setInPaused(false)
          _adb_mediacontext().resetAssetRefContext()
          m._playUnhandledFromPrerollWaitTime = false
        End Function,
        _cmdPause: Function(reContext as Object) As Void
          _adb_mediacontext().setInPaused(true)
          _adb_mediacontext().resetAssetRefContext()
        End Function,
        _cmdSeekStart: Function(reContext as Object) As Void
          _adb_mediacontext().setInSeeking(true)
          _adb_mediacontext().resetAssetRefContext()
        End Function,
        _cmdSeekComplete: Function(reContext as Object) As Void
          if _adb_mediacontext().isSeeking()
            _adb_mediacontext().setInSeeking(false)
            _adb_mediacontext().resetAssetRefContext()
          end if
        End Function,
        _cmdBufferStart: Function(reContext as Object) As Void
          _adb_mediacontext().setInBuffering(true)
          _adb_mediacontext().resetAssetRefContext()
        End Function,
        _cmdBufferComplete: Function(reContext as Object) As Void
          if _adb_mediacontext().isBuffering()
            _adb_mediacontext().setInBuffering(false)
            _adb_mediacontext().resetAssetRefContext()
          end if
        End Function,
        _cmdStartPlayheadTimer: Function(reContext as Object) As Void
          m._logger.debug("#::_cmdStartPlayheadTimer()")
          _adb_clockservice().startTimer(_adb_clockservice().id_playhead_timer)
        End Function,
        _cmdStopPlayheadTimer: Function(reContext as Object) As Void
          m._logger.debug("#::_cmdStopPlayheadTimer()")
          _adb_clockservice().stopTimer(_adb_clockservice().id_playhead_timer)
          ' Get out of stall state if we are in it.
          m._cmdStallComplete()
        End Function,
        ' This function is responsible for tracking when state changes occur in middle of
        ' reporting quantum w.r.t previous ping.
        _cmdFlushQuantum: Function(reContext as Object) As Void
            reportingTimer = _adb_clockservice().getTimerHandle(_adb_clockservice().id_reporting_timer)
            if reportingTimer <> invalid
              if reportingTimer.elapsedTime() > 250
                m._cmdTrackPlaybackState(reContext)
              end if
            end if
        End Function,
        _cmdBitrate: Function(reContext as Object) As Void
          m._trackInternal(_adb_paramsResolver()._bitrate_change)
        End Function,
        _cmdError: Function(reContext as Object) As Void
          errorId = reContext.getData(m._KEY_ERROR_ID)
          errorSource = reContext.getData(m._KEY_ERROR_SOURCE)
          info = {}
          info["s:event:source"] = errorSource
          info["s:event:id"] = errorId
          m._trackInternal(_adb_paramsResolver()._error, info)
        End Function,
        _cmdTrackPlaybackState: Function(reContext as Object) As Void
          m._logger.debug("#_cmdTrackPlaybackState()")
          if m._isTrackingSuspended
            m._logger.debug("#_cmdTrackPlaybackState: Tracking Suspended, not sending any ping.")
            return
          end if
          if _adb_mediacontext().isSeeking()
            m._logger.debug("#_cmdTrackPlaybackState: In Seek State, not sending any ping.")
            return
          end if
          m._trackInternal(_adb_mediacontext().getCurrentPlaybackState())
          _adb_mediacontext().resetAssetRefContext()
          reportingTimer = _adb_clockservice().getTimerHandle(_adb_clockservice().id_reporting_timer)
          if reportingTimer <> invalid
            reportingTimer.reset()
          end if
        End Function,
        _cmdPlayheadUpdate: Function(reContext as Object) As Void
          playhead = reContext.getData(m._KEY_PLAYHEAD)
          _adb_mediacontext().updateCurrentPlayhead(playhead)
        End Function,
        _cmdQoSUpdate: Function(reContext as Object) As Void
          qosObject = reContext.getData(m._KEY_QOS_OBJECT)
          _adb_mediacontext().setQoSInfo(qosObject)
        End Function,
        _cmdDisableMedia: Function(reContext as Object) As Void
          m._logger.debug("#_cmdDisableMedia: Media tracking disabled remotely.")
          m._isEnabled = false
        End Function,
' **************************************************************************
' Video Idle / Resume
' **************************************************************************
        _cmdDetectVideoIdle: Function(reContext as Object) As Void
          if m._isTrackingSuspended
            if (NOT _adb_mediacontext().isVideoIdle())
              m._logger.debug("#_cmdDetectVideoIdle: [Video resumes] suspendTracking -> resumeTracking")
              m._resumeTracking()
            else
              m._logger.debug("#_cmdDetectVideoIdle: [Video idle] Stays in suspendTracking")
              return
            end if
          end if
          if _adb_mediacontext().isVideoIdle() AND (_adb_mediacontext().getDurationSinceIdleState() > m._MAX_SESSION_INACTIVITY)
            m._logger.debug("#_cmdDetectVideoIdle: [Video idle] Enters suspendTracking")
            m._suspendTracking()
            return
          end if
        End Function,
        _suspendTracking: Function() As Void
' Suspend heartbeat pings if the media stays in paused / stalled / seeking state for _MAX_SESSION_INACTIVITY ms.
          m._logger.debug("#_suspendTracking()")
          m._trackInternal(_adb_paramsResolver()._media_end)
          m._isTrackingSuspended = true
        End Function,
        _resumeTracking: Function() As Void
          m._logger.debug("#_resumeTracking()")
          adInfo = invalid
          adData = invalid
          adBreakInfo = invalid
          chapterInfo = invalid
          chapterData = invalid
          isInAd = false
          isInChapter = false
          if _adb_mediacontext().isInAd()
            isInAd = true
            adInfo = _adb_mediacontext().getAdInfo()
            adData = _adb_mediacontext().getAdContextData()
            adBreakInfo = _adb_mediacontext().getAdBreakInfo()
          end if
          if _adb_mediacontext().isInChapter()
            isInChapter = true
            chapterInfo = _adb_mediacontext().getChapterInfo()
            chapterData = _adb_mediacontext().getChapterContextData()
          end if
          _adb_mediacontext().resetToResumeState()
          _adb_paramsResolver().resetSessionIds()
          m._isTrackingSuspended = false
          m._trackInternal(_adb_paramsResolver()._media_start)
          m._trackInternal(_adb_paramsResolver()._media_resume)
          if isInChapter
            _adb_mediacontext().setInChapterTo(true)
            _adb_mediacontext().setChapterInfo(chapterInfo)
            _adb_mediacontext().setChapterContextData(chapterData)
            m._trackInternal(_adb_paramsResolver()._chapter_start)
          end if
          if isInAd
            _adb_mediacontext().setInAdTo(true)
            _adb_mediacontext().setAdBreakInfo(adBreakInfo)
            _adb_mediacontext().setAdInfo(adInfo)
            _adb_mediacontext().setAdContextData(adData)
            m._trackInternal(_adb_paramsResolver()._ad_start)
          end if
          ' Manually issue a play call.
          m._cmdTrackPlaybackState(invalid)
          ' We usually resume tracking
          ' 1) In response to a API call getting the media module out of idle state
          ' (In such cases, we start playhead timer as an API call action)
          ' 2) When the player automatically gets out of stall state
          ' (In such cases, playhead timer will already be running)
        End Function,
' **************************************************************************
' Stall Tracking
' **************************************************************************
        _cmdDetectVideoStall: Function(reContext as Object) As Void
          if NOT _adb_mediacontext().isInAdBreak()
            currentPlayhead = reContext.getData(m._KEY_PLAYHEAD)
            if currentPlayhead <> m._previousContentPlayhead
                ' Get out of stall state if we are in it.
                m._cmdStallComplete()
            else if m._previousContentPlayhead >= 0 AND (NOT _adb_mediacontext().isInStall())
                m._stalledPlayheadCount += 1
                if m._stalledPlayheadCount >= m._MAX_STALLED_PLAYHEAD_COUNT
                  m._cmdStallStart()
                end if
            end if
            m._previousContentPlayhead = currentPlayhead
          else
            ' Get out of stall state if we are in it.
            m._cmdStallComplete()
          end if
        End Function,
        _cmdStallStart: Function() As Void
            m._logger.debug("#_cmdStallStart()")
            m._cmdFlushQuantum(invalid)
            _adb_mediacontext().setInStall(true)
            _adb_mediacontext().resetAssetRefContext()
        End Function
        _cmdStallComplete: Function() As Void
          if _adb_mediacontext().isInStall()
            m._logger.debug("#_cmdStallComplete()")
            m._cmdFlushQuantum(invalid)
            _adb_mediacontext().setInStall(false)
            _adb_mediacontext().resetAssetRefContext()
          end if
          m._stalledPlayheadCount = 0
        End Function,
' **************************************************************************
' Content Start Ping
' **************************************************************************
        _cmdDetectContentStart: Function(reContext as Object) As Void
          if NOT m._contentStarted AND NOT _adb_mediacontext().isInAd() AND _adb_mediacontext().isPlaying()
            currentPlayhead = reContext.getData(m._KEY_PLAYHEAD)
            if m._firstContentPlayhead = invalid
              m._firstContentPlayhead = currentPlayhead
            else if currentPlayhead > 0 AND currentPlayhead <> m._firstContentPlayhead
              m._logger.debug("#_cmdDetectContentStart: Sending Content Start ping.")
              m._cmdTrackPlaybackState(reContext)
              m._contentStarted = true
            end if
          end if
        End Function,
' **************************************************************************
' Private Methods
' **************************************************************************
        _disableMedia: Function() As Void
          m._logger.debug("#::disableMedia()")
          m._processRule(m._Rule.DisableMedia)
          m._processRule(m._Rule.SessionEnd)
        End Function,
        _processRule: Function(rule as String, reContext = invalid as Object) as Boolean
          m._ruleEngine.processRule(rule, reContext)
        End Function,
        _setupRules: Function() As Void
          m._ruleEngine.registerEnterExitAction("_cmdEnterAction", "_cmdExitAction")
          m._ruleEngine.registerRule(m._Rule.SessionStart, "API:trackSessionStart", [
            m._ruleEngine.createPredicate("_isError", false, m._ErrorMessage.ErrInConfigErrorState),
            m._ruleEngine.createPredicate("_isMediaDisabled", false, m._ErrorMessage.ErrMediaDisabled),
            m._ruleEngine.createPredicate("_isTracking", false, m._ErrorMessage.ErrInTracking),
            m._ruleEngine.createPredicate("_isValidMediaObject", true, m._ErrorMessage.ErrInvalidMediaObject),
          ], [
            "_cmdConfigure",
            "_cmdSessionStart"
          ], m)
          m._ruleEngine.registerRule(m._Rule.SessionEnd, "API:trackSessionEnd", [
            m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
          ], [
            "_cmdHandleMediaComplete",
            "_cmdFlushQuantum",
            "_cmdAdSkip",
            "_cmdAdBreakComplete",
            "_cmdChapterSkip",
            "_cmdVideoEnd",
            "_cmdSessionEnd"
          ], m)
          m._ruleEngine.registerRule(m._Rule.VideoComplete, "API:trackComplete", [
            m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
            m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
          ], [
            "_cmdFlushQuantum",
            "_cmdStopPlayheadTimer",
            "_cmdAdSkip",
            "_cmdAdBreakComplete",
            "_cmdChapterSkip",
            "_cmdVideoEnd",
          ], m)
          m._ruleEngine.registerRule(m._Rule.Error, "API:trackError", [
              m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
              m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
            ], [
              "_cmdError",
          ], m)
          m._ruleEngine.registerRule(m._Rule.Play, "API:trackPlay", [
            m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
            m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
            m._ruleEngine.createPredicate("_doAllowPlayerStateChange", true, m._ErrorMessage.ErrInvalidPlayerState),
          ], [
            "_cmdFlushQuantum",
            "_cmdSeekComplete",
            "_cmdBufferComplete",
            "_cmdPlay",
            "_cmdDetectVideoIdle",
            "_cmdTrackPlaybackState",
            "_cmdStartPlayheadTimer",
          ], m)
          m._ruleEngine.registerRule(m._Rule.Pause, "API:trackPause", [
            m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
            m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
            m._ruleEngine.createPredicate("_doAllowPlayerStateChange", true, m._ErrorMessage.ErrInvalidPlayerState),
            m._ruleEngine.createPredicate("_isInBuffer", false, m._ErrorMessage.ErrInBuffer),
            m._ruleEngine.createPredicate("_isInSeek", false, m._ErrorMessage.ErrInSeek),
          ], [
            "_cmdFlushQuantum",
            "_cmdStopPlayheadTimer",
            "_cmdPause",
            "_cmdTrackPlaybackState"
          ], m)
          m._ruleEngine.registerRule(m._Rule.BufferStart, "API:trackEvent(BufferStart)", [
            m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
            m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
            m._ruleEngine.createPredicate("_doAllowPlayerStateChange", true, m._ErrorMessage.ErrInvalidPlayerState),
            m._ruleEngine.createPredicate("_isInBuffer", false, m._ErrorMessage.ErrInBuffer),
            m._ruleEngine.createPredicate("_isInSeek", false, m._ErrorMessage.ErrInSeek),
          ], [
            "_cmdFlushQuantum",
            "_cmdStopPlayheadTimer",
            "_cmdBufferStart",
            "_cmdTrackPlaybackState"
          ], m)
          m._ruleEngine.registerRule(m._Rule.BufferComplete, "API:trackEvent(BufferComplete)", [
            m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
            m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
            m._ruleEngine.createPredicate("_doAllowPlayerStateChange", true, m._ErrorMessage.ErrInvalidPlayerState),
            m._ruleEngine.createPredicate("_isInBuffer", true, m._ErrorMessage.ErrNotInBuffer),
          ], [
            "_cmdFlushQuantum",
            "_cmdBufferComplete",
            "_cmdDetectVideoIdle",
            "_cmdStartPlayheadTimer"
          ], m)
          m._ruleEngine.registerRule(m._Rule.SeekStart, "API:trackEvent(SeekStart)", [
            m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
            m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
            m._ruleEngine.createPredicate("_doAllowPlayerStateChange", true, m._ErrorMessage.ErrInvalidPlayerState),
            m._ruleEngine.createPredicate("_isInBuffer", false, m._ErrorMessage.ErrInBuffer),
            m._ruleEngine.createPredicate("_isInSeek", false, m._ErrorMessage.ErrInSeek),
          ], [
            "_cmdFlushQuantum",
            "_cmdStopPlayheadTimer",
            "_cmdSeekStart"
          ], m)
          m._ruleEngine.registerRule(m._Rule.SeekComplete, "API:trackEvent(SeekComplete)", [
            m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
            m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
            m._ruleEngine.createPredicate("_doAllowPlayerStateChange", true, m._ErrorMessage.ErrInvalidPlayerState),
            m._ruleEngine.createPredicate("_isInSeek", true, m._ErrorMessage.ErrNotInSeek),
          ], [
            "_cmdFlushQuantum",
            "_cmdSeekComplete",
            "_cmdDetectVideoIdle",
            "_cmdStartPlayheadTimer"
          ], m)
          m._ruleEngine.registerRule(m._Rule.AdBreakStart, "API:trackEvent(AdBreakStart)", [
            m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
            m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
            m._ruleEngine.createPredicate("_isValidAdBreakObject", true, m._ErrorMessage.ErrInvalidAdBreakObject),
            m._ruleEngine.createPredicate("_isDifferentAdBreakObject", true, m._ErrorMessage.ErrDuplicateAdBreakObject),
          ], [
              "_cmdFlushQuantum",
              "_cmdAdSkip",
              "_cmdAdBreakComplete",
              "_cmdAdBreakStart"
          ], m)
          m._ruleEngine.registerRule(m._Rule.AdBreakComplete, "API:trackEvent(AdBreakComplete)", [
              m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
              m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
              m._ruleEngine.createPredicate("_isInAdBreak", true, m._ErrorMessage.ErrNotInAdBreak),
          ], [
              "_cmdFlushQuantum",
              "_cmdAdSkip",
              "_cmdAdBreakComplete"
          ], m)
          m._ruleEngine.registerRule(m._Rule.AdStart, "API:trackEvent(AdStart)", [
              m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
              m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
              m._ruleEngine.createPredicate("_isInAdBreak", true, m._ErrorMessage.ErrNotInAdBreak),
              m._ruleEngine.createPredicate("_isValidAdObject", true, m._ErrorMessage.ErrInvalidAdObject),
              m._ruleEngine.createPredicate("_isDifferentAdObject", true, m._ErrorMessage.ErrDuplicateAdObject)
          ], [
              "_cmdFlushQuantum",
              "_cmdAdSkip",
              "_cmdAdStart"
          ], m)
          m._ruleEngine.registerRule(m._Rule.AdComplete, "API:trackEvent(AdComplete)", [
              m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
              m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
              m._ruleEngine.createPredicate("_isInAdBreak", true, m._ErrorMessage.ErrNotInAdBreak),
              m._ruleEngine.createPredicate("_isInAd", true, m._ErrorMessage.ErrNotInAd)
          ], [
              "_cmdFlushQuantum",
              "_cmdAdComplete"
          ], m)
          m._ruleEngine.registerRule(m._Rule.AdSkip, "API:trackEvent(AdSkip)", [
              m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
              m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
              m._ruleEngine.createPredicate("_isInAdBreak", true, m._ErrorMessage.ErrNotInAdBreak),
              m._ruleEngine.createPredicate("_isInAd", true, m._ErrorMessage.ErrNotInAd)
          ], [
              "_cmdFlushQuantum",
              "_cmdAdSkip"
          ], m)
          m._ruleEngine.registerRule(m._Rule.ChapterStart, "API:trackEvent(ChapterStart)", [
              m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
              m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
              m._ruleEngine.createPredicate("_isValidChapterObject", true, m._ErrorMessage.ErrInvalidChapterObject),
              m._ruleEngine.createPredicate("_isDifferentChapterObject", true, m._ErrorMessage.ErrDuplicateChapterObject),
          ], [
              "_cmdFlushQuantum",
              "_cmdChapterSkip",
              "_cmdChapterStart"
          ], m)
          m._ruleEngine.registerRule(m._Rule.ChapterComplete, "API:trackEvent(ChapterComplete)", [
              m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
              m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
              m._ruleEngine.createPredicate("_isInChapter", true, m._ErrorMessage.ErrNotInChapter)
          ], [
              "_cmdFlushQuantum",
              "_cmdChapterComplete"
          ], m)
          m._ruleEngine.registerRule(m._Rule.ChapterSkip, "API:trackEvent(ChapterSkip)", [
              m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
              m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
              m._ruleEngine.createPredicate("_isInChapter", true, m._ErrorMessage.ErrNotInChapter)
          ], [
              "_cmdFlushQuantum",
              "_cmdChapterSkip"
          ], m)
          m._ruleEngine.registerRule(m._Rule.BitrateChange, "API:trackEvent(BitrateChange)", [
              m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
              m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
          ], [
              "_cmdBitrate"
          ], m)
          m._ruleEngine.registerRule(m._Rule.DisableMedia, "DisableMedia", [
              m._ruleEngine.createPredicate("_isMediaDisabled", false, m._ErrorMessage.ErrNotInTracking)
          ], [
              "_cmdDisableMedia"
          ], m)
          m._ruleEngine.registerRule(m._Rule.PlayheadUpdate, "API:updatePlayhead", [
              m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
              m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
          ], [
              "_cmdPlayheadUpdate"
          ], m)
          m._ruleEngine.registerRule(m._Rule.QosUpdate, "API:updateQoSData", [
              m._ruleEngine.createPredicate("_isTracking", true, m._ErrorMessage.ErrNotInTracking),
              m._ruleEngine.createPredicate("_isInMedia", true, m._ErrorMessage.ErrNotInMedia),
              m._ruleEngine.createPredicate("_isValidQoSInfoObject", true, m._ErrorMessage.ErrInvalidQoSInfo),
          ], [
              "_cmdQoSUpdate"
          ], m)
        End Function,
        _resetTrackingState: Function() As Void
          m._isTrackingSuspended = false
          m._trackLoadInfo = invalid
          m._stalledPlayheadCount = 0
          m._previousContentPlayhead = -1
          'We set this flag after playhead has initially moved by 1 sec.
          m._contentStarted = false
          m._firstContentPlayhead = invalid
          m._prerollWaitEnabled = true
          m._prerollWaitTime = m._CONST_PREROLL_WAIT_TIME
          m._playReceived = false
          m._playUnhandledFromPrerollWaitTime = false
          m._playTaskHandle = invalid
          _adb_task_scheduler().clearTasks()
          _adb_mediacontext().resetState()
          _adb_paramsResolver().resetSessionIds()
        End Function,
        _trackInternal: Function(eventType as String, additionalInfo = invalid as Object) As Void
          m._logger.debug("#sendHit( " + eventType + " )")
          if m._isTrackingSuspended
            m._logger.debug("#sendHit( " + eventType + " ) - inIdleState")
            'We don't send any pings if MediaHeartbeat is in IDLE_STATE.
            return
          end if
          dictionary = _adb_paramsResolver().resolveDataForEvent(eventType)
          'Error pings provide additional info. This will be useful once we support custom events.
          if additionalInfo <> invalid
            dictionary.append(additionalInfo)
          end if
          _adb_serializeAndSendHeartbeat().queueRequestsForResponse(dictionary)
          if eventType = _adb_paramsResolver()._media_start
            contextData = _adb_paramsResolver().getContextData(_adb_paramsResolver()._media_start)
            _adb_trackAction("", contextData)
            dictionary_aa_start = _adb_paramsResolver().resolveDataForEvent(_adb_paramsResolver()._aa_start)
            _adb_serializeAndSendHeartbeat().queueRequestsForResponse(dictionary_aa_start)
          else if eventType = _adb_paramsResolver()._ad_start
            contextData = _adb_paramsResolver().getContextData(_adb_paramsResolver()._ad_start)
            _adb_trackAction("", contextData)
            dictionary_aa_ad_start = _adb_paramsResolver().resolveDataForEvent(_adb_paramsResolver()._aa_ad_start)
            _adb_serializeAndSendHeartbeat().queueRequestsForResponse(dictionary_aa_ad_start)
          end if
        End Function,
        _cleanContextData: Function(contextData as Object) As Object
          res = {}
          if type(contextData) = "roAssociativeArray"
            for each key in contextData
              valType = type(contextData[key])
              if valType = "String" OR valType="roString"
                res[key] = contextData[key]
              else if valType = "roInt" OR valType = "roInteger" OR valType = "Integer"
                res[key] = contextData[key]
              else if valType = "roFloat" OR valType = "Float" OR valType = "Double"
                res[key] = contextData[key]
              else if valType = "roBoolean" OR valType = "Boolean"
                res[key] = contextData[key]
              end if
            end for
          end if
          return res
        End Function,
        _setConstants: Function() As Void
          ' Context Keys
          m._KEY_CONTEXTDATA_MEDIATYPE = "a.media.streamType"
          m._KEY_MEDIA_OBJECT = "key_media_object"
          m._KEY_ADBREAK_OBJECT = "key_adbreak_object"
          m._KEY_AD_OBJECT = "key_ad_object"
          m._KEY_CHAPTER_OBJECT = "key_chapter_object"
          m._KEY_CUSTOM_METADATA = "key_custom_metadata"
          m._KEY_ERROR_ID = "key_error_id"
          m._KEY_ERROR_SOURCE = "key_error_source"
          m._KEY_QOS_OBJECT = "key_qos_object"
          m._KEY_PLAYHEAD = "key_playhead"
          m._Rule = {
            SessionStart: "sessionstart",
            SessionEnd: "sessionend",
            VideoComplete: "videocomplete",
            Play: "play",
            Pause: "pause",
            Error: "error",
            AdBreakStart: "adbreakstart",
            AdBreakComplete: "adbreakcomplete",
            AdStart: "adstart",
            AdComplete: "adcomplete",
            AdSkip: "adskip",
            ChapterStart: "chapterstart",
            ChapterComplete: "chaptercomplete",
            ChapterSkip: "chapterskip",
            SeekStart: "seekstart",
            SeekComplete: "seekcomplete",
            BufferStart: "bufferstart",
            BufferComplete: "buffercomplete",
            BitrateChange: "bitratechange",
            TimedMetadataUpdate: "timedmetadataupdate",
            QosUpdate : "qosupdate",
            PlayheadUpdate : "playheadupdate",
            DisableMedia : "disablemedia"
          }
          m._ErrorMessage = {
            ErrInConfigErrorState : "Media module is in error state and can not start a tracking session. Make sure the Adobe Mobile config is valid.",
            ErrMediaDisabled : "Media module is disabled for this publisher. Please contact Adobe Representative to enable tracking.",
            ErrNotInTracking: "Media module is not in active tracking session, call 'API:mediaTrackSessionStart' to begin a new tracking session.",
            ErrInTracking: "Media module is in active tracking session, call 'API:mediaTrackSessionEnd' to end current tracking session.",
            ErrNotInMedia: "Media module has completed tracking session, call 'API:mediaTrackSessionEnd' first to end current session and then begin a new tracking session.",
            ErrInBuffer: "Media module is tracking buffer events, call 'API:mediaTrackEvent(MediaBufferComplete)' first to stop tracking buffer events.",
            ErrNotInBuffer: "Media module is not tracking buffer events, call 'API:mediaTrackEvent(MediaBufferStart)' before 'API:mediaTrackEvent(MediaBufferComplete)'.",
            ErrInSeek: "Media module is tracking seek events, call 'API:mediaTrackEvent(MediaSeekComplete)' first to stop tracking seek events.",
            ErrNotInSeek: "Media module is not tracking seek events, call 'API:mediaTrackEvent(MediaSeekStart)' before 'API:mediaTrackEvent(MediaSeekComplete)'.",
            ErrNotInAdBreak: "Media module is not tracking any AdBreak, call 'API:mediaTrackEvent(mediaTrackSessionStart)' to begin tracking AdBreak",
            ErrNotInAd: "Media module is not tracking any Ad, call 'API:mediaTrackEvent(MediaAdStart)' to begin tracking Ad",
            ErrNotInChapter: "Media module is not tracking any Chapter, call 'API:mediaTrackEvent(MediaChapterStart)' to begin tracking Chapter",
            ErrInvalidMediaObject: "MediaInfo passed into 'API:mediaTrackSessionStart' is invalid.",
            ErrInvalidAdBreakObject: "AdBreakInfo passed into 'API:mediaTrackEvent(mediaTrackSessionStart)' is invalid.",
            ErrDuplicateAdBreakObject: "Media module is currently tracking the AdBreak passed into 'API:mediaTrackEvent(mediaTrackSessionStart)'.",
            ErrInvalidAdObject: "AdInfo passed into 'API:mediaTrackEvent(MediaAdStart)' is invalid.",
            ErrDuplicateAdObject: "Media module is currently tracking the Ad passed into 'API:mediaTrackEvent(MediaAdStart)'.",
            ErrInvalidChapterObject: "ChapterInfo passed into 'API:mediaTrackEvent(MediaChapterStart)' is invalid.",
            ErrDuplicateChapterObject: "Media module is currently tracking the Chapter passed into 'API:mediaTrackEvent(MediaChapterStart)'.",
            ErrInvalidQoSInfo : "QosInfo passed into 'API:mediaUpdateQoS' is invalid",
            ErrInvalidPlayerState : "Media module is tracking an AdBreak but not tracking any Ad and will drop any calls to track player state (Play, Pause, Buffer or Seek) in this state."
        }
          ' Constant to enable/disable GranularAdTracking. When enabled we sent a tracking ping every second for the Ad.
          ' This is now a private key but should be exposed through MediaObjectKey object for later releases.
          m._MediaObjectKey_GranularAdTracking = "granular_ad_tracking"
          m._MAX_STALLED_PLAYHEAD_COUNT = 2
          m._MAX_SESSION_INACTIVITY = 30 * 60 * 1000 'Production :- ~30 mins
          'm._MAX_SESSION_INACTIVITY = 30 * 1000 'Testing :- ~30 secs
          m._CONST_PREROLL_WAIT_TIME = 250 'ms
          m._DEFAULT_AD_TRACKING_INTERVAL = 1000 'ms
          m._DEFAULT_CONTENT_TRACKING_INTERVAL = 10000 'ms
        End Function,
    }
    instance._init()
    GetGlobalAA()["_adb_media_instance"] = instance
  endif
  return GetGlobalAA()._adb_media_instance
End Function
' Error Handling util methods for ADB_MEDIA
Function _adb_media_setErrorState(boolval As Boolean)
  if boolval = true
    _adb_persistenceLayer().writeValue("media_error_state", "true")
    if GetGlobalAA()._adb_media_instance <> invalid
      'Clear current session, if any.
      if _adb_mediacontext().isActiveTracking()
        _adb_media()._resetTrackingState()
      end if
    end if
  elseif boolval = false
    _adb_persistenceLayer().writeValue("media_error_state", "false")
    ' We start tracking with the next trackSessionStart call.
  end if
End Function
Function _adb_media_isInErrorState() As Boolean
  mediaErrorState = _adb_persistenceLayer().readValue("media_error_state")
  if mediaErrorState <> invalid AND mediaErrorState = "true"
    return true
  end if
  return false
End Function

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
Function _adb_mediacontext() As Object
  if GetGlobalAA()._mediaContext = invalid
      instance = {
        _init: Function() As Void
          m.resetState()
        End Function,
        setInAdTo: Function(flag As Boolean) As Void
          m["isInAdValue"] = flag
        End Function,
        setIsActiveTracking: Function(flag As Boolean) As Void
          m["isActiveTrackingValue"] = flag
        End Function,
        setInChapterTo: Function(flag As Boolean) As Void
          m["isInChapterValue"] = flag
        End Function,
        isActiveTracking: Function() As Boolean
          return m["isActiveTrackingValue"]
        End Function,
        isBuffering: Function() As Boolean
          return m["isBufferingValue"]
        End Function,
        isInAd: Function() As Boolean
          return m["isInAdValue"]
        End Function,
        isInAdBreak: Function() As Boolean
          return _adb_mediacontext().getAdBreakInfo() <> invalid
        End Function,
        isInChapter: Function() As Boolean
          return m["isInChapterValue"]
        End Function,
        isActiveSession: Function() As Boolean
          return m["_isSessionActive"]
        End Function,
        setIsActiveSession: Function(value As Boolean) As Boolean
          m["_isSessionActive"] = value
        End Function,
        setInBuffering: Function(flag As Boolean)
          m["isBufferingValue"] = flag
          m.recordTSForIdleState()
        End Function,
        setInPaused: Function(flag As Boolean)
          m["isPausedValue"] = flag
          m["isPlaybackStartedValue"] = true
          m.recordTSForIdleState()
        End Function,
        isPaused: Function() As Boolean
          return m["isPausedValue"]
        End Function,
        isPlaying: Function() As Boolean
          return m["isPlaybackStartedValue"] AND (NOT m.isPaused()) AND (NOT m.isBuffering()) AND (NOT m.isSeeking()) AND (NOT m.isInStall())
        End Function,
        hasPlaybackStarted: Function() As Boolean
          return m["isPlaybackStartedValue"]
        End Function,
        setInSeeking: Function(flag As Boolean)
          m["isSeekingValue"] = flag
          m.recordTSForIdleState()
        End Function,
        isSeeking: Function() As Boolean
          return m["isSeekingValue"]
        End Function,
        setInStall: Function(flag As Boolean)
          m["isInStallValue"] = flag
          m.recordTSForIdleState()
        End Function,
        isInStall: Function() As Boolean
          return m["isInStallValue"]
        End Function,
        ''' getter methods to get the player info
        getMediaInfo: Function() As Object
          return m["currMediaInfo"]
        End Function,
        getAdBreakInfo: Function() As Object
          return m["currAdBreakInfo"]
        End Function,
        getAdInfo: Function() As Object
          return m["currAdInfo"]
        End Function,
        getChapterInfo: Function() As Object
          return m["currChapterInfo"]
        End Function,
        getQoSInfo: Function() As Object
          return m["currQoSInfo"]
        End Function,
        getMediaContextData: Function() As Object
          return m["currMediaContextData"]
        End Function,
        getChapterContextData: Function() As Object
          return m["currChapterContextData"]
        End Function,
        getAdContextData: Function() As Object
          return m["currAdContextData"]
        End Function,
        ''' setter methods to set the player info/metadata callbacks
        setMediaInfo: Function(info As Object) As Void
          m["currMediaInfo"] = info
        End Function,
        setAdBreakInfo: Function(info As Object) As Void
          m["currAdBreakInfo"] = info
        End Function,
        setAdInfo: Function(info As Object) As Void
          m["currAdInfo"] = info
        End Function,
        setChapterInfo: Function(info As Object) As Void
          m["currChapterInfo"] = info
        End Function,
        setQoSInfo: Function(info As Object) As Void
          m["currQoSInfo"] = info
        End Function,
        setMediaContextData: Function(contextData As Object) As Void
          m["currMediaContextData"] = contextData
        End Function,
        setAdContextData: Function(contextData As Object) As Void
          m["currAdContextData"] = contextData
        End Function,
        setChapterContextData: Function(contextData As Object) As Void
          m["currChapterContextData"] = contextData
        End Function,
        resetToResumeState: Function() as Void
          ' Resets Event timestamps, Ad info and chapter info
          m["eventTSMap"] = {}
          m["assetRefContext"] = {}
          m.setAdBreakInfo(invalid)
          m.setInAdTo(false)
          m.setAdInfo(invalid)
          m.setAdContextData(invalid)
          m.setInChapterTo(false)
          m.setChapterInfo(invalid)
          m.setChapterContextData(invalid)
        End Function,
        resetState: Function() as Void
          m.setIsActiveTracking(false)
          m.setIsActiveSession(false)
          m["isPlaybackStartedValue"] = false
          m["isBufferingValue"] = false
          m["isInStallValue"] = false
          m["isPausedValue"] = false
          m["isSeekingValue"] = false
          m["isVideoIdleValue"] = false
          m["idleStateTs"] = _adb_util().getTimestampInMillis()
          m["playhead"] = 0
          m["currQoSInfo"] = invalid
          m["forcedBufferState"] = false
          m.setMediaInfo(invalid)
          m.setMediaContextData(invalid)
          m.resetToResumeState()
        End Function,
        resetAssetRefContext: Function() As Void
          'This function is called to track the duration of the player state event. (start, play, pause, stall, buffer)
          'This should be called always after tracking player state event.
          m.assetRefContext.state = m.getCurrentPlaybackState()
          m.assetRefContext.ts = _adb_util().getTimestampInMillis()
          m.assetRefContext.playhead = m.getCurrentPlayhead()
        End Function,
        getAssetRefContext: Function() As Object
          return m.assetRefContext
        End Function,
        updateTimeStampForEvent: Function(eventName As String, ts As String) As Void
          m.eventTSMap[eventName] = ts
        End Function,
        getTimeStampForEvent: Function(eventName As String) As Object
          if m.eventTSMap[eventName] = invalid
            m.eventTSMap[eventName] = "-1"
          endif
          return m.eventTSMap[eventName]
        End Function,
        updateCurrentPlayhead: Function(playhead As Integer) As Void
          m["playhead"] = playhead
        End Function,
        getCurrentPlayhead: Function() As Integer
          return m["playhead"]
        End Function,
        isInForcedBufferState: Function() As Boolean
          return m["forcedBufferState"]
        End Function,
        forceStateToBuffering: Function(flag As Boolean) As Void
          m["forcedBufferState"] = flag
        End Function,
' Tbd :- Remove dependency to _adb_paramsResolver from here. Move constants to seperate object.
        getCurrentPlaybackState: Function() As Object
          if m.isInForcedBufferState()
            return _adb_paramsResolver()._media_event_buffer
          else if m.isInStall()
            return _adb_paramsResolver()._media_event_stall
          else if m.isBuffering()
            return _adb_paramsResolver()._media_event_buffer
          else if m.isPaused() OR m.isSeeking()
            return _adb_paramsResolver()._media_event_pause
          else if m.isPlaying()
            return _adb_paramsResolver()._media_event_play
          else
            return _adb_paramsResolver()._media_event_start
          end if
        End Function,
        recordTSForIdleState: Function() As Void
            isIdle = m.isPaused() OR m.isBuffering() OR m.isSeeking() OR m.isInStall()
            if(m.isVideoIdle() <> isIdle)
              m["idleStateTS"] = _adb_util().getTimestampInMillis()
            endif
            m["isVideoIdleValue"] = isIdle
        End Function,
        getDurationSinceIdleState: Function() As Integer
          if m.isVideoIdle()
            idleTs = m["idleStateTS"]
            currentTs = _adb_util().getTimestampInMillis()
            return _adb_util().calculateTimeDiffInMillis(currentTs, idleTs)
          else
            return 0
          endif
        End Function,
        isVideoIdle: Function() As Boolean
          return m["isVideoIdleValue"]
        End Function,
      }
      instance._init()
      GetGlobalAA()["_mediaContext"] = instance
  endif
  return GetGlobalAA()._mediaContext
End Function

' *************************************************************************
' *
' * ADOBE CONFIDENTIAL
' * ___________________
' *
' *  Copyright 2018 Adobe Systems Incorporated
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
Function _adb_media_object() As Object
  if GetGlobalAA()._adb_media_object = invalid
    instance = {
      _logger : _adb_logger().instanceWithTag("media/MediaObject"), 
      isValidMediaInfoObject:Function(mediaInfo As Object) As Boolean
        if mediaInfo.id = invalid
          m._logger.warning("MediaInfo does not have a value for media-id")
          return false
        endif
        if mediaInfo.length = invalid
          m._logger.warning("MediaInfo does not have a value for the length of the content")
          return false
        endif
        return true
      End Function,
      isValidAdBreakInfoObject:Function(adBreakInfo As Object) As Boolean
        if adBreakInfo["position"] = invalid
          m._logger.warning("AdBreak Info does not have value for position")
          return false
         endif
          
        return true
      End Function,
      isValidAdInfoObject:Function(adInfo As Object) As Boolean
        if adInfo["id"] = invalid
          m._logger.warning("Ad Info does not have value for ad id")
          return false
        endif
          
        return true
      End Function,
      isValidChapterInfoObject:Function(chapterInfo As Object) As Boolean
        if chapterInfo["position"] = invalid
          m._logger.warning("Chapter Info does not have value for chapter position")
          return false
        endif
        if chapterInfo["name"] = invalid
          m._logger.warning("Chapter Info does not have value for chapter name")
          return false
        endif
        if chapterInfo["offset"] = invalid
          m._logger.warning("Chapter Info does not have value for chapter offset")
           return false
        endif
        if chapterInfo["length"] = invalid
          m._logger.warning("Chapter Info does not have value for chapter length")
          return false
        endif
        return true
      End Function,
      isValidQoSInfoObject:Function(qosInfo As Object) As Boolean
        if qosInfo["droppedFrames"] = invalid
          m._logger.warning("QoS Info does not have value for dropped frames")
          return false
        endif
        if qosInfo["startupTime"] = invalid
          m._logger.warning("QoS Info does not have value for startup time")
          return false
        endif
        if qosInfo["fps"] = invalid
          m._logger.warning("QoS Info does not have value for frames per second")
          return false
        endif
        if qosInfo["bitrate"] = invalid
          m._logger.warning("QoS Info does not have value for bitrate")
          return false
        endif
        return true
      End Function,
      isSameAdBreakInfoObject: Function(adbreak1 As Object, adbreak2 As Object) As Boolean
          if adbreak1 = invalid AND adbreak2 = invalid 
            return true
          else if adbreak1 = invalid AND adbreak2 <> invalid 
            return false
          else if adbreak1 <> invalid AND adbreak2 = invalid 
            return false
          else 
            return (adbreak1.name = adbreak2.name) AND (adbreak1.startTime = adbreak2.startTime) AND (adbreak1.position = adbreak2.position)
          end if
      End Function,
      isSameAdInfoObject: Function(ad1 as Object, ad2 as Object) As Boolean 
        if ad1 = invalid AND ad2 = invalid 
            return true
          else if ad1 = invalid AND ad2 <> invalid 
            return false
          else if ad1 <> invalid AND ad2 = invalid 
            return false
          else 
            return (ad1.id = ad2.id) AND (ad1.name = ad2.name) AND (ad1.length = ad2.length) AND (ad1.position = ad2.position)
          end if
      End Function,
      isSameChapterInfoObject: Function(chapter1 as Object, chapter2 as Object) As Boolean
        if chapter1 = invalid AND chapter2 = invalid 
            return true
          else if chapter1 = invalid AND chapter2 <> invalid 
            return false
          else if chapter1 <> invalid AND chapter2 = invalid 
            return false
          else 
            return (chapter1.name = chapter2.name) AND (chapter1.length = chapter2.length) AND (chapter1.position = chapter2.position) AND (chapter1.offset = chapter2.offset)
          end if
        return false
      End Function
    }
    GetGlobalAA()["_adb_media_object"] = instance
  end if
  return GetGlobalAA()._adb_media_object
End Function
' *****************************
' Public APIs
' ****************************
Function adb_media_init_mediainfo(name As String, id As String, length As Double, streamType As String, mediaType = invalid As Dynamic) As Object
    o = CreateObject("roAssociativeArray")
    o.id            = id
    o.name          = name
    o.length        = length
    o.streamType    = streamType
    dataType = type(mediaType)
    if (dataType = "String" OR dataType="roString") AND mediaType = ADBMobile().MEDIA_TYPE_AUDIO
      o.mediaType = ADBMobile().MEDIA_TYPE_AUDIO
    else
      o.mediaType = ADBMobile().MEDIA_TYPE_VIDEO
    end if
    return o
End Function
Function adb_media_init_adinfo(name As String, id As String, position As Double, length As Double) As Object
    o = CreateObject("roAssociativeArray")
    o.id            = id
    o.name          = name
    o.length        = length
    o.position      = position
    return o
End Function
Function adb_media_init_chapterinfo(name As String, position As Double, length As Double, startTime As Double) As Object
    o = CreateObject("roAssociativeArray")
    o.name          = name
    o.length        = length
    o.position      = position
    o.offset        = startTime
    return o
End Function
Function adb_media_init_adbreakinfo(name As String, startTime as Double, position as Double) As Object
    o = CreateObject("roAssociativeArray")
    o.name          = name
    o.startTime     = startTime
    o.position      = position
    return o
End Function
Function adb_media_init_qosinfo(bitrate As Double, startupTime as Double, fps as Double, droppedFrames as Double) As Object
    o = CreateObject("roAssociativeArray")
    o.bitrate       = bitrate
    o.fps           = fps
    o.droppedFrames = droppedFrames
    o.startupTime   = startupTime
    return o
End Function

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
Function _adb_paramsResolver() As Object
  if GetGlobalAA()._paramsResolver = invalid
      instance = {
        resolveDataForEvent: Function(eventName As String) As Object
          resolvedData = {}
          ''' common data
          '''analytics specific (s:sc:)
          m._appendAnalyticsData(resolvedData)
          ''' user and audience manager data
          m._appendUserData(resolvedData)
          m._appendAAMData(resolvedData)
          '''service provider config specific - (s:sp:)
          m._appendServiceData(resolvedData)
          '''asset specific - reset here always - (l:asset:)
          m._appendCommonAssetData(resolvedData)
          '''common stream specific - update (l:stream:)
          m._appendCommonStreamData(resolvedData)
          
          ''' event specific data.
          if eventName = m._aa_start
            m._appendEventData(resolvedData, eventName)
            m._appendCUserData(resolvedData)
          else if eventName = m._aa_ad_start
            m._appendEventData(resolvedData, eventName)
          else if eventName= m._media_start
            m["_mediaSessionIdValue"] = invalid
            m._appendEventData(resolvedData, "start")
            
            m._appendMediaMetadata(resolvedData)
          else if eventName= m._ad_start
            'reset the ad_sid to invalid before every AdStart, fix for VHL-652
            m["_adSessionIdValue"] = invalid
            m._appendEventData(resolvedData, "start")
            m._appendMediaMetadata(resolvedData)
            m._appendAdMetadata(resolvedData)
          else if eventName= m._ad_complete
            m._appendEventData(resolvedData, "complete")
          else if eventName = m._chapter_start
            m["_chapterSessionIdValue"] = invalid
            m._appendEventData(resolvedData,eventName)
            m._appendMediaMetadata(resolvedData)
            m._appendChapterMetadata(resolvedData)
          else if eventName = m._chapter_complete
            m._appendEventData(resolvedData,eventName)
          else if eventName= m._media_complete
            m._appendEventData(resolvedData, "complete")
          
          else if eventName= m._media_end
            m._appendEventData(resolvedData, "end")
          else
            'append the eventName anyway. bitrate_change, resume, play, pause, stall, start, error
            m._appendEventData(resolvedData, eventName)
          end if
          '''session (s:event:sid)
          resolvedData[m._event_sid] = m._mediaSessionId()
          'We ignore Ad & Chapter asset data when we issue _media_end event. 
          'This happens when we are already in an Ad/Chapter and enter into idle state.
          'We ignore Ad asset data when we issue chapter_start and chapter_complete event
          'This happens when we issue ChapterStart from inside an Ad.
          if _adb_mediacontext().isInAd() = true
            if  eventName <> m._media_end AND eventName <> m._chapter_start AND eventName <> m._chapter_complete
              m._appendAdAssetData(resolvedData)
            end if
          end if
          if _adb_mediacontext().isInChapter() = true
            if  eventName <> m._media_end
              m._appendChapterStreamData(resolvedData)
            end if
          end if
          return resolvedData
        End Function,
        getContextData: Function(eventName as String) As Object
          contextData = {}
          if eventName = m._media_start
            mediaMetadata = _adb_mediacontext().getMediaContextData()
            if mediaMetadata <> invalid
              contextData.append(mediaMetadata)
            endif
            mediaInfo = _adb_mediacontext().getMediaInfo()
            contextData["a.contentType"] = mediaInfo.streamType
            contextData["a.media.name"] = mediaInfo.id
            contextData["a.media.friendlyName"] = mediaInfo.name
            contextData["a.media.length"] = mediaInfo.length
            contextData["a.media.playerName"] = _adb_config().mPlayerName
            contextData["a.media.channel"] = _adb_config().mChannel
            contextData["a.media.view"] = "true"
            contextData["a.media.vsid"] = m._mediaSessionId()
            if mediaInfo.mediaType = ADBMobile().MEDIA_TYPE_AUDIO
              contextData["&&pev3"] = "audio"
              contextData["&&ms_a"] = "1"
            else
              contextData["&&pev3"] = "video"
            endif
            contextData["&&pe"] = "ms_s"
            ' appending customer ids to support AAM's declared id
            if _adb_audienceManager().getDpid() <> invalid
              contextData["&&cid.userId.id"] = _adb_audienceManager().getDpid()
            endif
            if _adb_audienceManager().getDpuuid() <> invalid
              contextData["&&cid.puuid.id"] = _adb_audienceManager().getDpuuid()
            endif
          elseif eventName = m._ad_start
            mediaMetadata = _adb_mediacontext().getMediaContextData()
            adMetadata = _adb_mediacontext().getAdContextData()
            if mediaMetadata <> invalid
              contextData.append(mediaMetadata)
            endif
            if adMetadata <> invalid
              contextData.append(adMetadata)
            endif
            mediaInfo = _adb_mediacontext().getMediaInfo()
            adInfo = _adb_mediacontext().getAdInfo()
            adBreakInfo = _adb_mediacontext().getAdBreakInfo()
            assetIdMD5 = _adb_util().generateMD5(mediaInfo.id)
            podId = assetIdMD5 + "_" + Str(adBreakInfo.position).Trim()
            contextData["a.contentType"] = mediaInfo.streamType
            contextData["a.media.name"] = mediaInfo.id
            contextData["a.media.playerName"] = _adb_config().mPlayerName
            contextData["a.media.channel"] = _adb_config().mChannel
            contextData["a.media.vsid"] = m._mediaSessionId()
            contextData["a.media.friendlyName"] = mediaInfo.name
            contextData["a.media.length"] = mediaInfo.length
            contextData["a.media.ad.name"] = adInfo.id
            contextData["a.media.ad.friendlyName"] = adInfo.name
            contextData["a.media.ad.podFriendlyName"] = adBreakInfo.name
            contextData["a.media.ad.length"] = adInfo.length
            contextData["a.media.ad.playerName"] = _adb_config().mPlayerName
            contextData["a.media.ad.pod"] = podId
            contextData["a.media.ad.podPosition"] = adInfo.position
            contextData["a.media.ad.podSecond"] = adBreakInfo.startTime
            contextData["a.media.ad.view"] = "true"
            if mediaInfo.mediaType = ADBMobile().MEDIA_TYPE_AUDIO
              contextData["&&pev3"] = "audioAd"
              contextData["&&ms_a"] = "1"
            else
              contextData["&&pev3"] = "videoAd"
            endif
            contextData["&&pe"] = "msa_s"
            ' appending customer ids to support AAM's declared id
            if _adb_audienceManager().getDpid() <> invalid
              contextData["&&cid.userId.id"] = _adb_audienceManager().getDpid()
            endif
            if _adb_audienceManager().getDpuuid() <> invalid
              contextData["&&cid.puuid.id"] = _adb_audienceManager().getDpuuid()
            endif
          endif
          return contextData
        End Function,
        resetSessionIds: Function() As Void
        ' When we restart a session after long pause, we manually reset session ids before resuming'
          m["_mediaSessionIdValue"] = invalid
          m["_chapterSessionIdValue"] = invalid
          m["_adSessionIdValue"] = invalid
        End Function,
        _appendCUserData: Function(resolvedData As Object) As Void
          if _adb_audienceManager().getDpid() <> invalid
            resolvedData[m._cuser_id] = _adb_audienceManager().getDpid()
          endif
          if _adb_audienceManager().getDpuuid() <> invalid
            resolvedData[m._cuser_puuid] = _adb_audienceManager().getDpuuid()
          endif
        End Function,
        _appendAnalyticsData: Function(resolvedData As Object) As Void
          resolvedData[m._analytics_rsid] = _adb_config().reportSuiteIDs
          resolvedData[m._analytics_trackingserver] = _adb_config().trackingServer
          if _adb_config().ssl = true or _adb_config().ssl = 1
            resolvedData[m._analytics_ssl] = 1
          else
            resolvedData[m._analytics_ssl] = 0
          endif
        End Function,
        _appendUserData: Function(resolvedData As Object) As Void
          resolvedData[m._user_aid] = _adb_aid().aid
          resolvedData[m._user_mid] = _adb_visitor().marketingCloudID()
          resolvedData[m._user_vid] = _adb_config().userIdentifier
        End Function,
        _appendAAMData: Function(resolvedData As Object) As Void
          analyticsParams = _adb_visitor().analyticsParameters()
          if analyticsParams <> invalid 
            if analyticsParams["aamb"] <> invalid
              resolvedData[m._aam_blob] = analyticsParams["aamb"]
            endif
            if analyticsParams["aamlh"] <> invalid
              resolvedData[m._aam_loc_hint] = analyticsParams["aamlh"]
            endif
          endif
        End Function,
        _appendServiceData: Function(resolvedData As Object) As Void
          resolvedData[m._service_sdk] = _adb_config().mSdk
          resolvedData[m._service_apilevel] = _adb_media_version().getApiLevel()
          resolvedData[m._service_channel] =  _adb_config().mChannel
          resolvedData[m._service_ovp] = _adb_config().ovp
          resolvedData[m._service_playername] = _adb_config().mPlayerName
          resolvedData[m._service_hbversion] = _adb_media_version().getVersion()
        End Function,
        _appendCommonStreamData: Function(resolvedData As Object) As Void
          mediaInfo = _adb_mediacontext().getMediaInfo()
          if mediaInfo <> invalid
            resolvedData[m._stream_type] = mediaInfo["streamType"]
          end if
          qosInfo = _adb_mediacontext().getQoSInfo()
          if qosInfo <> invalid
            resolvedData[m._stream_droppedFrames] = qosInfo.droppedFrames
            resolvedData[m._stream_startup_time] = qosInfo.startupTime
            resolvedData[m._stream_fps] = qosInfo.fps
            resolvedData[m._stream_bitrate] = qosInfo.bitrate
          endif
        End Function,
        _appendCommonAssetData: Function(resolvedData As Object) As Void
          mediaInfo = _adb_mediacontext().getMediaInfo()
          resolvedData[m._asset_type] = "main"
          if mediaInfo <> invalid
            resolvedData[m._asset_mediaid] = mediaInfo.id
            resolvedData[m._asset_duration] = mediaInfo.length
            resolvedData[m._asset_name] = mediaInfo.name
          end if
          resolvedData[m._asset_publisher] = _adb_config().mPublisher
        End Function,
        _appendEventData: Function(resolvedData As Object, eventName as String) As Void
          currPlayhead = _adb_mediacontext().getCurrentPlayhead()
          if currPlayhead <> invalid
            resolvedData[m._event_playhead] = currPlayhead
          endif
          resolvedData[m._event_type] = eventName
          m._appendEventTS(resolvedData, eventName)
          m._appendEventDuration(resolvedData, eventName)
        End Function,
        _appendEventTS: Function(resolvedData As Object, eventName as String) As Void
          resolvedEventName = eventName
          if _adb_mediacontext().isInAd()
            currAd = _adb_mediacontext().getAdInfo()
            currAdID = currAd.id
            resolvedEventName = currAdID + "_" + eventName
          endif
          currTS = _adb_util().getTimestampInMillis()
          prevTS = _adb_mediacontext().getTimeStampForEvent(resolvedEventName)
          resolvedData[m._event_prevts] = prevTS
          resolvedData[m._event_ts] = currTS
          _adb_mediacontext().updateTimeStampForEvent(resolvedEventName, currTS)
        End Function,
' We only append event duration to playback state pings (event type = start / play / pause / stall / buffer).
' Other calls or first playback state ping will have an event duration value of 0.
' With pause and stall tracking in place, we send out a ping every 'reportingInterval' sec
' Important: Code to protect against events coming in after a long pause and resulting in large event durations.
' This usually happens when the ReportingTimer stops firing every requested interval.
' JS - Happens due to minimizing the browser / inactive tab / system sleep
' Android/iOS - Happens due to app going to background / system sleep
' Event Duration calculation. (The following steps are done sequentially)
' 1) For all calls which track duration (start, play, pause, buffer, stall) when calculated duration exceeds max duration (10mins) we return zero.
' 2) For all calls if we are inside an Ad, do not use playhead comparision as it may not change or use different values w.r.t media playhead values.
' 3) For all other play calls, if the difference between playheadDelta and calculated duration is less than max error delta (2sec), we return minimum of calculated duration and playhead duration.
        _appendEventDuration: Function(resolvedData As Object, eventName as String) As Void
          eventDuration = 0
          
          ' This object stores the ts and playhead of the last state ping issued.
          refContext = _adb_mediacontext().getAssetRefContext()
          ' Current playback event should be same as last stored event for us to calculate event duration.
          if refContext.state <> invalid AND refContext.state = eventName
            tsDelta = 0
            currTS = resolvedData[m._event_ts]
            if currTS <> invalid AND refContext.ts <> invalid
              tsDelta = _adb_util().calculateTimeDiffInMillis(currTS, refContext.ts)
            end if
            eventDuration = tsDelta
            if tsDelta > m._MAX_ACCEPTED_EVENT_DURATION
              m._logger.warning(" Resetting duration to 0 as calculated duration (" + tsDelta.ToStr() + " ms) exceeds 10 mins")
              eventDuration = 0
            else if refContext.state = m._media_event_play AND (NOT _adb_mediacontext().isInAd())
              currPlayhead = resolvedData[m._event_playhead]
              if currPlayhead <> invalid AND refContext.playhead <> invalid
                playheadDelta = Abs(currPlayhead - refContext.playhead) * 1000
                errorDelta = Abs(tsDelta - playheadDelta)
                if errorDelta > m._MAX_ACCEPTED_DURATION_ERROR_DELTA
                  eventDuration = m._min(tsDelta, playheadDelta)
                  m._logger.warning(" Resetting duration to " + eventDuration.ToStr() +" ms as calculated error delta (" + errorDelta.ToStr() + " ms) exceeds 2 secs")
                end if
              end if
            end if
          end if
          resolvedData[m._event_duration] = eventDuration
        End Function
        _appendAdAssetData: Function(resolvedData As Object) As Void
          resolvedData[m._asset_type] = "ad"
          adBreakInfo = _adb_mediacontext().getAdBreakInfo()
          if adBreakInfo <> invalid
            resolvedData[m._asset_resolver] = _adb_config().mPlayerName
            resolvedData[m._asset_podname] = adBreakInfo.name
            resolvedData[m._asset_podoffset] = adBreakInfo.startTime
            assetIdMD5 = _adb_util().generateMD5(resolvedData[m._asset_mediaid])
            resolvedData[m._asset_podid] = assetIdMD5 + "_" + Str(adBreakInfo.position).Trim()
          endif
          adInfo = _adb_mediacontext().getAdInfo()
          if adInfo <> invalid
            resolvedData[m._asset_adid] = adInfo.id
            resolvedData[m._asset_adname] = adInfo.name
            resolvedData[m._asset_adlength] = adInfo.length
            resolvedData[m._asset_adposition_in_pod] = adInfo.position
          end if
          resolvedData[m._asset_adsid] = m._adSessionId()
        End Function,
        _appendChapterStreamData: Function(resolvedData As Object) As Void
          resolvedData[m._stream_chaptersid] =  m._chapterSessionId()
          chapterInfo = _adb_mediacontext().getChapterInfo()
          if chapterInfo <> invalid
            resolvedData[m._stream_chapterpos] = chapterInfo.position
            ''' TODO: resolvedData[m._stream_chaptersid] = MD5 hash of media-id and chapterInfo["position"]
            mediaIdMD5 = _adb_util().generateMD5(resolvedData[m._asset_mediaid])
            resolvedData[m._stream_chapterid] = mediaIdMD5 + "_" + Str(resolvedData[m._stream_chapterpos]).Trim()
            resolvedData[m._stream_chaptername] = chapterInfo.name
            resolvedData[m._stream_chapteroffset] = chapterInfo.offset
            resolvedData[m._stream_chapterlength] = chapterInfo.length
          end if
        End Function,
        _appendMediaMetadata: Function(resolvedData As Object) As Void
          mediaMetadata = _adb_mediacontext().getMediaContextData()
            if mediaMetadata <> invalid
              for each key in mediaMetadata
                  paramKey = m["metaKey"] + key
                  resolvedData[paramKey] = mediaMetadata[key]
              end for
            endif
        End Function,
        _appendAdMetadata: Function(resolvedData As Object) As Void
          adMetadata = _adb_mediacontext().getAdContextData()
            if adMetadata <> invalid
              for each key in adMetadata
                  paramKey = m["metaKey"] + key
                  resolvedData[paramKey] = adMetadata[key]
              end for
            endif
        End Function,
        _appendChapterMetadata: Function(resolvedData As Object) As Void
          chapterMetadata = _adb_mediacontext().getChapterContextData()
            if chapterMetadata <> invalid
              for each key in chapterMetadata
                  paramKey = m["metaKey"] + key
                  resolvedData[paramKey] = chapterMetadata[key]
              end for
            endif
        End Function,
        _mediaSessionId: Function() As Object
          if m["_mediaSessionIdValue"] = invalid
            m["_mediaSessionIdValue"] = _adb_util().generateSessionId()
          end if
          return m["_mediaSessionIdValue"]
        End Function,
        _chapterSessionId: Function() As Object
          if m["_chapterSessionIdValue"] = invalid
            m["_chapterSessionIdValue"] = _adb_util().generateSessionId()
          end if
          return m["_chapterSessionIdValue"]
        End Function,
        _adSessionId: Function() As Object
          if m["_adSessionIdValue"] = invalid
            m["_adSessionIdValue"] = _adb_util().generateSessionId()
          end if
          return m["_adSessionIdValue"]
        End Function,
        _min: Function(num1 As Integer, num2 As Integer) As Integer
          if num1 < num2 
            return num1
          else
            return num2
          end if
        End Function,
        _init:Function() As Void
          m["_analytics_rsid"] = "s:sc:rsid"
          m["_analytics_trackingserver"] = "s:sc:tracking_server"
          m["_analytics_ssl"] = "h:sc:ssl"
          m["_user_aid"] = "s:user:aid"
          m["_user_mid"] = "s:user:mid"
          m["_user_vid"] = "s:user:id"
          m["_aam_blob"] = "s:aam:blob"
          m["_aam_loc_hint"] = "l:aam:loc_hint"
          m["_cuser_id"] = "s:cuser:userId.id"
          m["_cuser_puuid"] = "s:cuser:puuid.id"
          m["_service_sdk"] = "s:sp:sdk"
          m["_service_apilevel"] = "l:sp:hb_api_lvl"
          m["_service_channel"] = "s:sp:channel"
          m["_service_ovp"] = "s:sp:ovp"
          m["_service_playername"] = "s:sp:player_name"
          m["_service_hbversion"] = "s:sp:hb_version"
          m["_asset_type"] = "s:asset:type"
          m["_asset_publisher"] = "s:asset:publisher"
          m["_asset_mediaid"] = "s:asset:video_id"
          m["_asset_duration"] = "s:asset:duration"
          m["_asset_name"] = "s:asset:name"
          m["_stream_type"] = "s:stream:type"
          m["_stream_droppedFrames"] = "l:stream:dropped_frames"
          m["_stream_startup_time"] = "l:stream:startup_time"
          m["_stream_fps"] = "l:stream:fps"
          m["_stream_bitrate"] = "l:stream:bitrate"
          '''chapter sepecific stream info
          m["_stream_chaptersid"] = "s:stream:chapter_sid"
          m["_stream_chapterid"] = "s:stream:chapter_id"
          m["_stream_chaptername"] = "s:stream:chapter_name"
          m["_stream_chapteroffset"] = "l:stream:chapter_offset"
          m["_stream_chapterpos"] = "l:stream:chapter_pos"
          m["_stream_chapterlength"] = "l:stream:chapter_length"
          m["_asset_type"] = "s:asset:type"
          m["_asset_publisher"] = "s:asset:publisher"
          m["_asset_duration"] = "l:asset:length"
          '''ToDo : Keep the key on backend as video / media?
          m["_asset_mediaid"] = "s:asset:video_id"
          '''ad sepecific asset info
          m["_asset_resolver"] = "s:asset:resolver"
          m["_asset_adid"] = "s:asset:ad_id"
          m["_asset_adsid"] = "s:asset:ad_sid"
          m["_asset_podid"] = "s:asset:pod_id"
          m["_asset_adposition_in_pod"] = "s:asset:pod_position"
          m["_asset_type"] = "s:asset:type"
          m["_asset_adname"] = "s:asset:ad_name"
          m["_asset_adlength"] = "l:asset:ad_length"
          m["_asset_podname"] = "s:asset:pod_name"
          m["_asset_podoffset"] = "l:asset:pod_offset"
          m["_event_sid"] = "s:event:sid"
          m["_event_ts"] = "l:event:ts"
          m["_event_prevts"] = "l:event:prev_ts"
          m["_event_type"] = "s:event:type"
          m["_event_duration"] = "l:event:duration"
          m["_event_playhead"] = "l:event:playhead"
          m["_mediaSessionIdValue"] = invalid
          m["_chapterSessionIdValue"] = invalid
          m["_adSessionIdValue"] = invalid
          m["metaKey"] = "s:meta:"
          m["_aa_start"] = "aa_start"
          m["_aa_ad_start"] = "aa_ad_start"
          m["_bitrate_change"] = "bitrate_change"
          m["_chapter_start"] = "chapter_start"
          m["_chapter_complete"] = "chapter_complete"
          m["_ad_start"] = "media-ad-start"
          m["_ad_complete"] = "media-ad-complete"
          m["_media_start"] = "media-start"
          m["_media_complete"] = "media-complete"
          m["_media_end"] = "media-end"
          m["_media_resume"] = "resume"
          m["_media_event_play"] = "play"
          m["_media_event_pause"] = "pause"
          m["_media_event_buffer"] = "buffer"
          m["_media_event_stall"] = "stall"
          m["_media_event_start"] = "start"
          m["_error"] = "error"
          m["_MAX_ACCEPTED_EVENT_DURATION"] = 600 * 1000 'milli seconds (10mins)
          m["_MAX_ACCEPTED_DURATION_ERROR_DELTA"] = 2 * 1000 'milli seconds (2sec)
          m["_logger"] = _adb_logger().instanceWithTag("media/paramsResolver")
        End Function
      }
      instance._init()
      GetGlobalAA()["_paramsResolver"] = instance
  end if
  return GetGlobalAA()._paramsResolver
End Function

' *************************************************************************
' *
' * ADOBE CONFIDENTIAL
' * ___________________
' *
' *  Copyright 2018 Adobe Systems Incorporated
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
Function _adb_ruleenginecontext() As Object
  instance = {
    _init: Function() As Void
      m._processAction = true
      m._store = {}
    End Function,
    setRuleName : Function(ruleName as String) As Void
      m._ruleName = ruleName
    End Function,
    getRuleName : Function() as String
      return m._ruleName
    End Function,
    setData : Function(key as String, value as Dynamic) As Void
      m._store[key] = value
    End Function,
    getData : Function(key as String) as Dynamic
      return m._store[key]
    End Function,
    shouldProcessAction : Function() As Boolean
      return m._processAction
    End Function,
    stopProcessingAction : Function() As Void
      m._processAction = false
    End Function,
    startProcessingAction : Function() As Void
      m._processAction = true
    End Function,
  }
  instance._init()
  return instance
End Function
Function _adb_ruleengine() As Object
  instance = {
    _init: Function() As Void
        m._rules = CreateObject("roArray", 20, true)
        m._logger = _adb_logger().instanceWithTag("media/RuleEngine")
    End Function,
    registerRule: Function(name as String, desc as String, preconditions as Object, actions as Object, scope as Object) As Void
      m._rules.Push({
        name : name, 
        desc : desc,
        preconditions : preconditions,
        actions : actions,
        scope : scope
      })
    End Function,
    createContext: Function() As Object
      return _adb_ruleenginecontext()
    End Function,
    createPredicate: Function(fn as String, expectedValue as Boolean, errorMsg as String) As Object
      return {
        fn : fn, 
        expectedValue : expectedValue,
        errorMsg : errorMsg
      }
    End Function,
    registerEnterExitAction : Function(enterAction as String, exitAction as String) As Void
      m._enterAction = enterAction
      m._exitAction = exitAction
    End Function,
    _handleFailure : Function(rule as Object, precondition as Object) As Void
      m._logger.debug(rule.desc + " - " + precondition.errorMsg)
    End Function,
    _getRule : Function(name as String) As Object
      for each rule in m._rules 
        if name = rule.name
          return rule
        end if
      end for
      return invalid
    End Function,
    processRule : Function(ruleName as String, reContext = invalid as Object) As Boolean
      retValue = true
      rule = m._getRule(ruleName)
      if rule <> invalid 
        scope = rule.scope
        if reContext = invalid
          reContext = m.createContext()
        end if
        reContext.setRuleName(ruleName)
        checkFailed = false
        for each precondition in rule.preconditions
          ret = scope[precondition.fn](reContext)
          checkFailed = (ret <> precondition.expectedValue)
          if checkFailed 
            m._handleFailure(rule, precondition)
            exit for
          end if 
        end for
        if checkFailed = false
          reContext.startProcessingAction()
          if m._enterAction <> invalid and scope[m._enterAction] <> invalid
            scope[m._enterAction](reContext)
          end if
          for each action in rule.actions
            if reContext.shouldProcessAction() = false
              m._logger.warning("Stopping actions for rule " + rule.desc)
              exit for
            end if
            if action <> invalid and scope[action] <> invalid
              scope[action](reContext)
            end if 
          end for
          if m._exitAction <> invalid and scope[m._exitAction] <> invalid and reContext.shouldProcessAction()
             scope[m._exitAction](reContext)
          end if
        else 
          retValue = false
        end if
      else
        m._logger.warning("No registered event found for ruleName " + ruleName)
        retValue = false
      end if
      return retValue
    End Function
  }
  instance._init()
  return instance
End Function

' *************************************************************************
' *
' * ADOBE CONFIDENTIAL
' * ___________________
' *
' *  Copyright 2018 Adobe Systems Incorporated
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
Function _adb_task(id as Integer, taskFn as String, scope as Object, interval as Integer) as Object
  instance = {
    elapsedTime: Function(timeElapsed as Integer) as Void
      m.remainingInterval -= timeElapsed
    End Function,
    shouldExecute: Function() as Boolean
      return m.remainingInterval <= 0
    End Function,
    execute: Function() as Void
      if m.scope[m.taskFn] <> invalid
        m.scope[m.taskFn]()
      end if
    End Function
  }
  instance.id = id
  instance.taskFn = taskFn
  instance.scope = scope
  instance.interval = interval
  instance.remainingInterval = interval
  return instance
End Function
Function _adb_task_scheduler() As Object
  if GetGlobalAA()._adb_task_scheduler = invalid
    instance = {
        _init: Function() as Void
          m._logger = _adb_logger().instanceWithTag("media/TaskScheduer")
          m._id = 0
          m._tasks = []
          m._pausedTasks = []
          m._timer = invalid
        End Function,
        
        _getCurrentTimeInMS: Function() as Double
          dateTime = CreateObject("roDateTime")
          currMS = dateTime.GetMilliseconds()
          timeInSeconds# = dateTime.AsSeconds()
          return (timeInSeconds# * 1000) +  currMS
        End Function,
        _runTasksForTime: Function(time as Double) As Void
          tasksToRun = []
          elapsedTime =  time - m._lastTickTime
          m._lastTickTime = time
          i = 0
          while i < m._tasks.Count()
            task = m._tasks[i]
            task.elapsedTime(elapsedTime)
            if task.shouldExecute()
              tasksToRun.Push(task)
              m._tasks.Delete(i)
            else
              i += 1
            end if
          end while
          m._checkStopTimer()
          ' Now execute the tasks.
          for each task in tasksToRun
              task.execute()
          end for
        End Function,
        _timerTicked: Function() As Boolean
          if (m._timer <> invalid)
            return m._timer.ticked()
          end if
          return false
        End Function,
        _onTick: Function() As Void
          now = m._getCurrentTimeInMS()
          m._runTasksForTime(now)
        End Function,
        _startTimer: Function() As Void
          if m._timer = invalid
            m._logger.debug("#startTimer()")
            m._lastTickTime = m._getCurrentTimeInMS()
              m._timer = _adb_timer()
              m._timer.start(250, "TaskSchedulerTimer") ' We tick every 250 ms
          end if
        End Function,
        _stopTimer: Function() As Void
          if m._timer <> invalid
              m._logger.debug("#stopTimer()")
              m._timer.stop()
              m._timer = invalid
          end if
        End Function,
        _checkStartTimer : Function() As Void
          if m._tasks.Count() > 0
            m._startTimer()
          end if
        End Function,
    
        _checkStopTimer: Function() As Void
          if m._tasks.Count() = 0
              m._stopTimer()
          end if
        End Function
        _removeTask: Function(taskArray As Object, task As Object) As Boolean
          if taskArray = invalid OR task = invalid
            return false
          end if
          i = 0
          while i < taskArray.Count()
            if taskArray[i].id = task.id
              taskArray.Delete(i)
              return true
            end if
            i += 1
          end while 
          return false
        End Function,
        scheduleTask: Function (taskFn as String, scope as Object, timeAfter as Integer) as Object
          m._logger.debug("#scheduleTask()")
          if(scope = invalid OR scope[taskFn] = invalid)
            return invalid
          end if
          ' Unique id to compare objects.
          m._id += 1
          task = _adb_task(m._id, taskFn, scope, timeAfter)
          m._tasks.push(task)
          m._checkStartTimer()
          return task
        End Function,
        cancelTask: Function (task as Object) As Void
          m._logger.debug("#cancelTask()")
          if m._removeTask(m._tasks, task)
            m._checkStopTimer()
          end if
        End Function,
        pauseTask: Function(task as Object) As Void
          m._logger.debug("#pauseTask()")
          if m._removeTask(m._tasks, task)
              m._pausedTasks.push(task)
              m._checkStopTimer()
          end if
        End Function,
        resumeTask: Function (task as Object) As Void
          m._logger.debug("#resumeTask()")
          if m._removeTask(m._pausedTasks, task)
              m._tasks.push(task)
              m._checkStartTimer()
          end if
        End Function,
        clearTasks: Function() As Void
          m._stopTimer()
          m._tasks = []
          m._pausedTasks = []        
        End Function
    }
    instance._init()
    GetGlobalAA()["_adb_task_scheduler"] = instance
  end if
  return GetGlobalAA()._adb_task_scheduler
End Function
Function _adb_taskscheduler_loop() As Void
  if _adb_task_scheduler()._timerTicked()
    _adb_task_scheduler()._onTick()
  end if
End Function

' *************************************************************************
' *
' * ADOBE CONFIDENTIAL
' * ___________________
' *
' *  Copyright 2018 Adobe Systems Incorporated
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
Function _adb_message_helper() as Object
  if GetGlobalAA()._adb_message_helper = invalid
    instance = {
      isInt: Function(value as Dynamic) as Boolean
        valType = type(value)
        return (valType = "roInteger" OR valType = "roInt" OR valType = "Integer")
      End Function,
      isFloat: Function(value as Dynamic) as Boolean
        valType = type(value)
        return (valType = "roFloat" OR valType = "Float" OR valType = "Double")
      End Function, 
      isNumber: Function(value as Dynamic) as Boolean
        return m.isInt(value) OR m.isFloat(value)
      End Function,
      isString: Function(value as Dynamic) as Boolean
        valType = type(value)
        return (valType = "String" OR valType="roString")
      End Function,
      toString: Function(value as Dynamic) as Dynamic
        if m.isString(value)
          return value
        elseif m.isInt(value)
          return value.ToStr()
        elseif m.isFloat(value)
          return Str(value).Trim()
        else 
          return invalid
        endif
      End Function,
      tryParseNumber: Function(value as Dynamic) as Dynamic
        if m.isNumber(value)
          return value
        else if m.isString(value)
          ' Returns 0 for any invalid string
          num = Val(value)
          if num = 0 AND value.Trim() <> "0"
            return invalid
          end if
          return num
        else
          return invalid
        endif
      End Function
    }
    GetGlobalAA()["_adb_message_helper"] = instance
  end if
  return GetGlobalAA()._adb_message_helper
End Function

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
Function _adb_message(messageJson As Object) As Object
  instance = {
    _init: Function(messageJson As Object) As Boolean
      m["JSON_CONFIG_TEMPLATE"] = "template"
      m["JSON_CONFIG_MESSAGE_ID"] = "messageId"
      m["JSON_CONFIG_SHOW_RULE"] = "showRule"
      m["JSON_CONFIG_START_DATE"] = "startDate"
      m["MESSAGE_JSON_PAYLOAD"] = "payload"
      m["JSON_CONFIG_END_DATE"] = "endDate"
      m["JSON_CONFIG_SHOW_OFFLINE"] = "showOffline"
      m["JSON_CONFIG_AUDIENCES"] = "audiences"
      m["JSON_CONFIG_TRIGGERS"] = "triggers"
      m["JSON_CONFIG_ASSETS"] = "assets"
      m["MESSAGE_IMAGE_CACHE_DIR"] = "messageImages"
      m["JSON_DEFAULT_START_DATE"] = 0
      m["JSON_DEFAULT_SHOW_OFFLINE"] = "false"
      m["MESSAGE_ENUM_STRING_UNKNOWN"] = "unknown"
      m["MESSAGE_SHOW_RULE_STRING_ALWAYS"] = "always"
      m["MESSAGE_SHOW_RULE_STRING_ONCE"] = "once"
      m["MESSAGE_SHOW_RULE_STRING_UNTIL_CLICK"] = "untilClick"
      m["MESSAGE_TEMPLATE_STRING_ALERT"] = "alert"
      m["MESSAGE_TEMPLATE_STRING_FULLSCREEN"] = "fullscreen"
      m["MESSAGE_TEMPLATE_STRING_LOCAL_NOTIFICATION"] = "local"
      m["MESSAGE_TEMPLATE_STRING_CALLBACK"] = "callback"
      m["MESSAGE_TYPE_HANDLER"] = "handler"
      m["MESSAGE_TYPE"] = "type"
      m["COMBINED_VARS"] = "combinedVars"
      m["ADB_TEMPLATE_CALLBACK_URL"]       = "templateurl"
      m["ADB_TEMPLATE_CALLBACK_BODY"]      = "templatebody"
      m["ADB_TEMPLATE_CALLBACK_TYPE"]     = "contenttype"
      m["ADB_TEMPLATE_CALLBACK_TIMEOUT"]   = "timeout"
      m["ADB_TEMPLATE_TOKEN_START"]        = "{"
      m["ADB_TEMPLATE_TOKEN_END"]          = "}"
      m["ADB_TEMPLATE_TIMEOUT_DEFAULT"]    = 2
      m[m.JSON_CONFIG_MESSAGE_ID] = ""
      m[m.JSON_CONFIG_TEMPLATE] = ""
      m[m.MESSAGE_TYPE_HANDLER] = invalid
      m[m.JSON_CONFIG_START_DATE] = m.JSON_DEFAULT_START_DATE
      m[m.JSON_CONFIG_END_DATE] = invalid
      m[m.JSON_DEFAULT_SHOW_OFFLINE] = m.JSON_DEFAULT_SHOW_OFFLINE
      m[m.JSON_CONFIG_AUDIENCES] = []
      m[m.JSON_CONFIG_TRIGGERS] = []
      m[m.MESSAGE_TYPE] = invalid
      m[m.COMBINED_VARS] = {}
      m["validLetters"] = {}
      m.validLetters["a"] = 1
      m.validLetters["b"] = 1
      m.validLetters["c"] = 1
      m.validLetters["d"] = 1
      m.validLetters["e"] = 1
      m.validLetters["f"] = 1
      m.validLetters["g"] = 1
      m.validLetters["h"] = 1
      m.validLetters["i"] = 1
      m.validLetters["j"] = 1
      m.validLetters["k"] = 1
      m.validLetters["l"] = 1
      m.validLetters["m"] = 1
      m.validLetters["n"] = 1
      m.validLetters["o"] = 1
      m.validLetters["p"] = 1
      m.validLetters["q"] = 1
      m.validLetters["r"] = 1
      m.validLetters["s"] = 1
      m.validLetters["t"] = 1
      m.validLetters["u"] = 1
      m.validLetters["v"] = 1
      m.validLetters["w"] = 1
      m.validLetters["x"] = 1
      m.validLetters["y"] = 1
      m.validLetters["z"] = 1
      m.validLetters["0"] = 1
      m.validLetters["1"] = 1
      m.validLetters["2"] = 1
      m.validLetters["3"] = 1
      m.validLetters["4"] = 1
      m.validLetters["5"] = 1
      m.validLetters["6"] = 1
      m.validLetters["7"] = 1
      m.validLetters["8"] = 1
      m.validLetters["9"] = 1
      m.validLetters["_"] = 1
      m.validLetters["."] = 1
      m.validLetters["%"] = 1
      if messageJson <> invalid
        if messageJson[m.JSON_CONFIG_TEMPLATE] <> invalid
          m[m.JSON_CONFIG_TEMPLATE] = messageJson[m.JSON_CONFIG_TEMPLATE]
          if m[m.JSON_CONFIG_TEMPLATE] = m.MESSAGE_TEMPLATE_STRING_CALLBACK
            m[m.MESSAGE_TYPE_HANDLER] = _adb_message_template_callback()
            m[m.MESSAGE_TYPE] = m.MESSAGE_TEMPLATE_STRING_CALLBACK
          else
            _adb_logger().warning("Message - unable to create instance of message with that template")
            return false
          endif
        else
          _adb_logger().warning("Message - template is required for postback message")
          return false
        endif
      endif
      return m.setMsgJson(messageJson)
    End Function,
    setMsgJson: Function(messageJson as Object) As Boolean
      if messageJson <> invalid
        'messageId
        if messageJson[m.JSON_CONFIG_MESSAGE_ID] <> invalid AND messageJson[m.JSON_CONFIG_MESSAGE_ID].ToStr() <> ""
          m[m.JSON_CONFIG_MESSAGE_ID] = messageJson[m.JSON_CONFIG_MESSAGE_ID]
        else
          _adb_logger().warning("Message - unable to create instance of message without message id")
          return false
        endif
        'payload
        if messageJson[m.MESSAGE_JSON_PAYLOAD] <> invalid
          m[m.MESSAGE_JSON_PAYLOAD] = messageJson[m.MESSAGE_JSON_PAYLOAD]
          payloadParseSuccess = m.setPayload()
          if payloadParseSuccess = false
            return false
          endif
        else
          _adb_logger().warning("Data Callback - Unable to create data callback. payload is empty")
          return false
        endif
        'showRule
        if messageJson[m.JSON_CONFIG_SHOW_RULE] <> invalid AND messageJson[m.JSON_CONFIG_SHOW_RULE].ToStr() <> ""
          if messageJson[m.JSON_CONFIG_SHOW_RULE] = m[m.MESSAGE_ENUM_STRING_UNKNOWN]
            _adb_logger().warning("Message - Messages - Unable to create message. showrule is invalid")
            return false
          endif
          isValidShowRule = m.checkValidShowRule(messageJson[m.JSON_CONFIG_SHOW_RULE])
          if isValidShowRule = false
            _adb_logger().warning("Message - unsupported message rule")
            return false
          endif
          m[m.JSON_CONFIG_SHOW_RULE] = messageJson[m.JSON_CONFIG_SHOW_RULE]
        endif
        'startDate
        if messageJson[m.JSON_CONFIG_START_DATE] <> invalid AND messageJson[m.JSON_CONFIG_START_DATE].ToStr() <> ""
          startDate = messageJson[m.JSON_CONFIG_START_DATE]
        else
          startDate = m["JSON_DEFAULT_START_DATE"]
        endif
        m[m.JSON_CONFIG_START_DATE] = startDate
        'endDate
        if messageJson[m.JSON_CONFIG_END_DATE] <> invalid AND messageJson[m.JSON_CONFIG_END_DATE].ToStr() <> ""
          endDate = messageJson[m.JSON_CONFIG_END_DATE]
          m[m.JSON_CONFIG_END_DATE] = endDate
        else
          _adb_logger().warning("Message - cannot create message. endDate is invalid.")
          return false
        endif
        'showOffline
        if messageJson[m.JSON_CONFIG_SHOW_OFFLINE] <> invalid AND messageJson[m.JSON_CONFIG_SHOW_OFFLINE].ToStr() <> ""
          m[m.JSON_CONFIG_SHOW_OFFLINE] = messageJson[m.JSON_CONFIG_SHOW_OFFLINE]
        else
          m[m.JSON_CONFIG_SHOW_OFFLINE] = m[m.JSON_DEFAULT_SHOW_OFFLINE]
        endif
        'audiences
        if messageJson[m.JSON_CONFIG_AUDIENCES] <> invalid AND messageJson[m.JSON_CONFIG_AUDIENCES].count() > 0
          audiencesArray = messageJson[m.JSON_CONFIG_AUDIENCES]
          for each audience in audiencesArray
            matcher = _adb_message_matcher(audience)
            m[m.JSON_CONFIG_AUDIENCES].Push(matcher)
          endFor
        endif
        'triggers
        if messageJson[m.JSON_CONFIG_TRIGGERS] <> invalid AND messageJson[m.JSON_CONFIG_TRIGGERS].count() > 0
          triggersArray = messageJson[m.JSON_CONFIG_TRIGGERS]
          for each trigger in triggersArray
            matcher = _adb_message_matcher(trigger)
            m[m.JSON_CONFIG_TRIGGERS].Push(matcher)
          endFor
        endif
        if m[m.JSON_CONFIG_TRIGGERS].count() <= 0
          _adb_logger().warning("Messages - Unable to load message - at least one valid trigger is required for a message.")
          return false
        else
          _adb_logger().warning("Messages - " + m[m.JSON_CONFIG_TRIGGERS].count().toStr() + " triggers found")
        endif
        return true
      endif
      _adb_logger().warning("Messages - empty messages")
      return false
    End Function,
    setPayload: Function() As Boolean
      payload = m[m.MESSAGE_JSON_PAYLOAD]
      'templateURL
      if payload[m.ADB_TEMPLATE_CALLBACK_URL] <> invalid AND payload[m.ADB_TEMPLATE_CALLBACK_URL] <> ""
        m[m.ADB_TEMPLATE_CALLBACK_URL] = payload[m.ADB_TEMPLATE_CALLBACK_URL]
      else
        _adb_logger().warning("Data Callback - Unable to create data callback. templateurl is required")
        return false
      endif
      'timeout
      if payload[m.ADB_TEMPLATE_CALLBACK_TIMEOUT] <> invalid
        m[m.ADB_TEMPLATE_CALLBACK_TIMEOUT] = payload[m.ADB_TEMPLATE_CALLBACK_TIMEOUT]
      else
        _adb_logger().warning("Data Callback - setting default timeout")
        m[m.ADB_TEMPLATE_CALLBACK_TIMEOUT] = m[m.ADB_TEMPLATE_TIMEOUT_DEFAULT]
      endif
      'templatebody
      if payload[m.ADB_TEMPLATE_CALLBACK_BODY] <> invalid AND payload[m.ADB_TEMPLATE_CALLBACK_BODY].toStr() <> ""
        m[m.ADB_TEMPLATE_CALLBACK_BODY] = payload[m.ADB_TEMPLATE_CALLBACK_BODY]
        m[m.ADB_TEMPLATE_CALLBACK_TYPE] = payload[m.ADB_TEMPLATE_CALLBACK_TYPE]
      else
        _adb_logger().warning("Data Callback - Unable to read templatebody. This is not a required field")
      endif
      return true
    End Function,
    checkValidShowRule: Function(ruleName As String) As Boolean
      if ruleName = m.MESSAGE_SHOW_RULE_STRING_ALWAYS OR ruleName = MESSAGE_SHOW_RULE_STRING_ONCE
        return true
      endif
      return false
    End Function,
    shouldShowForVariables: Function(vars As Object, cData As Object) As Boolean
      m[m.COMBINED_VARS] = {}
      if cData <> invalid
        m[m.COMBINED_VARS].append(cData)
      endif
      if vars <> invalid
        m[m.COMBINED_VARS].append(vars)
      endif
      m.putMapForTemplatedTokens(m[m.COMBINED_VARS])
      'check within valid date
      dt = CreateObject ("roDateTime")
      secsGmt = dt.AsSeconds()
      startDate = m[m.JSON_CONFIG_START_DATE]
      if startDate <> invalid
        if secsGmt < startDate
          return false
        endif
      endif
      endDate = m[m.JSON_CONFIG_END_DATE]
      if endDate <> invalid
        if secsGmt > endDate
          return false
        endif
      endif
      'check audiences
      ' ???
      'check triggers
      triggers = m[m.JSON_CONFIG_TRIGGERS]
      if triggers <> invalid AND triggers.Count() > 0
        'ToDo check if we need to clean cData keys
        cdataCleaned = m.cleanContextDataDictionary(cData)
        for each matcher in triggers
          if matcher.matchesInMaps(vars, cdataCleaned) = false
            return false
          endif
        end for
      endif
      return true
    End Function,
    cleanContextDataDictionary : Function(cData As Object) As Object
      return cData
    End Function,
    putMapForTemplatedTokens: Function(vars As Object) As Void
      mapForTemplatedTokens = {}
      mapForTemplatedTokens["%mcid%"] = _adb_visitor().marketingCloudID()
      dt = CreateObject ("roDateTime")
      secsGmt = dt.AsSeconds()
      dtISO8601String = dt.ToISOString()
      'Convert the current time to ISO8601 format
      mapForTemplatedTokens["%timestampz%"] = dtISO8601String
      mapForTemplatedTokens["%timestampu%"] = secsGmt
      'Convert the current time to ISO8601 format
      mapForTemplatedTokens["%sdkver%"] = ADBMobile().version
      mapForTemplatedTokens["%cachebust%"] = Rnd(100000000).toStr()
      joinedVars = _adb_urlEncoder().serializeParameters(vars)
      if joinedVars.Len() > 2
        joinedVars = joinedVars.Mid(1)
      endif
      mapForTemplatedTokens["%all_url%"] = joinedVars
      if vars <> invalid
        joinedVarsJsonString = FormatJson(vars)
        if joinedVarsJsonString <> invalid
          mapForTemplatedTokens["%all_json%"] = joinedVarsJsonString
        endif
      endif
      m[m.COMBINED_VARS].append(mapForTemplatedTokens)
    End Function,
    show: Function() As Void
      templateURL = m[m.ADB_TEMPLATE_CALLBACK_URL]
      expandedURL = templateURL
      tokens = m.findTokensForExpansion(templateURL)
      urlExapnsions = m.buildExpansionsForTokens(tokens, true)
      nonEncodedParamsList = []
      nonEncodedParamsList.push("{%all_url%}")
      nonEncodedURLExpansions = m.buildExpansionsForTokens(nonEncodedParamsList,false)
      urlExapnsions.append(nonEncodedURLExpansions)
      if urlExapnsions <> invalid AND urlExapnsions.Count() > 0
        expandedURL = m.expandURL(templateURL,urlExapnsions)
      endif
      templateBody = m[m.ADB_TEMPLATE_CALLBACK_BODY]
      expandedBody = templateBody
      if templateBody <> invalid
        decodedBody = _adb_util().decodeBase64String(templateBody.toStr())
        bodyTokens = m.findTokensForExpansion(decodedBody)
        contentType = m[m.ADB_TEMPLATE_CALLBACK_TYPE]
        shouldEncodeBodyTokens = true
        if contentType <> invalid and LCase(contentType).Instr("application/json") <> -1
          shouldEncodeBodyTokens = false
        end if
        bodyExapnsions = m.buildExpansionsForTokens(bodyTokens,shouldEncodeBodyTokens)
        nonEncodedBodyParamsList = []
        nonEncodedBodyParamsList.push("{%all_url%}")
        nonEncodedBodyParamsList.push("{%all_json%}")
        nonEncodedBodyExpansions = m.buildExpansionsForTokens(nonEncodedBodyParamsList,false)
        bodyExapnsions.append(nonEncodedBodyExpansions)
        if bodyExapnsions <> invalid AND bodyExapnsions.Count() > 0
          expandedBody = m.expandURL(decodedBody,bodyExapnsions)
        endif
      endif
      _adb_message_worker().sendCallback(expandedURL,expandedBody)
    End Function,
    findTokensForExpansion: Function(stringWithTokens As Object) As Object
      tokens = []
      singleQuote = chr(34)
      if stringWithTokens <> invalid AND stringWithTokens.toStr() <> ""
        templateURLLength = stringWithTokens.Len()
        For i=0 To templateURLLength Step 1
          s = stringWithTokens.Mid(i,1)
          if s = m.ADB_TEMPLATE_TOKEN_START
            For j=i+1 to templateURLLength Step 1
              e = stringWithTokens.Mid(j,1)
              if e = m.ADB_TEMPLATE_TOKEN_END
                exit for
              endif
            End For
            if j = templateURLLength
              exit for
            endif
            token = stringWithTokens.Mid(i,j-i+1)
            if m.isValidToken(token.Mid(1,token.Len()-2)) = true
              tokens.push(token)
              i = j
            endif
          endif
        End For
      else
        _adb_logger().warning("findTokensForExpansion: empty string with tokens")
      endif
      return tokens
    End Function,
    buildExpansionsForTokens: Function(tokens As Object, urlEncodeExpansions As Boolean) As Object
      expansions = {}
      combinedVars = m[m.COMBINED_VARS]
      for each key in combinedVars.keys()
        keyStr = key.toStr()
        keyStr = LCase(keyStr)
        if type(keyStr) = "roString" OR type(keyStr) = "String"
          val = combinedVars[keyStr]
        endif
      end for
      combinedVarKeys = combinedVars.keys()
      for each token in tokens
        cleanToken = token.Mid(1,token.Len()-2).toStr()
        cleanToken = LCase(cleanToken)
        tokenObject = m[m.COMBINED_VARS].LookupCI(cleanToken)
        if tokenObject <> invalid
          if urlEncodeExpansions = true
            expansions[token] = _adb_urlEncoder()._serializeValue(tokenObject)
          else
            expansions[token] = tokenObject
          endif
        else
          expansions[token] = ""
        endif
      end for
      return expansions
    End Function,
    expandURL: Function(stringWithTokens As Object, expansions As Object) As Object
      resultExpandedURL = stringWithTokens
      for each expansion in expansions.keys()
        while (resultExpandedURL.Instr(expansion) <> -1)
          startIndex = resultExpandedURL.Instr(expansion)
          expansionValue = expansions.Lookup(expansion)
          preExpansionString = resultExpandedURL.Left(startIndex)
          postExpansionString = resultExpandedURL.Right(resultExpandedURL.Len() - (startIndex + expansion.Len()))
          if expansionValue <> ""
            resultExpandedURL = preExpansionString + expansionValue + postExpansionString
          else
            resultExpandedURL = preExpansionString + postExpansionString
          endif
        end while
      end for
      return resultExpandedURL
    End Function,
    isValidToken: Function(token As Object) As Boolean
      result = true
      For i=0 To token.Len()-1 Step 1
        s = token.Mid(i,1)
        s = LCase(s)
        if m.validLetters[s] = invalid
          result = false
          exit for
        endif
      End For
      return result
    End Function,
  }
  if instance._init(messageJson) = true
    return instance
  else
    _adb_logger().warning("Message - initialization failed!")
    return invalid
  endif
End Function

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
Function _adb_message_matcher(dictionary As Object) As Object
  instance = {
    _init: Function(dictionary As Object) As Void
      m["MESSAGE_JSON_KEY"] = "key"
      m["MESSAGE_JSON_MATCHES"] = "matches"
      m["MESSAGE_JSON_VALUES"] = "values"
      m["MESSAGE_MATCHER_STRING_EQUALS"] = "eq"
      m["MESSAGE_MATCHER_STRING_NOT_EQUALS"] = "ne"
      m["MESSAGE_MATCHER_STRING_GREATER_THAN"] = "gt"
      m["MESSAGE_MATCHER_STRING_LESS_THAN"] = "lt"
      m["MESSAGE_MATCHER_STRING_GREATER_THAN_OR_EQUALS"] = "ge"
      m["MESSAGE_MATCHER_STRING_LESS_THAN_OR_EQUALS"] = "le"
      m["MESSAGE_MATCHER_STRING_CONTAINS"] = "co"
      m["MESSAGE_MATCHER_STRING_NOT_CONTAINS"] = "nc"
      m["MESSAGE_MATCHER_STRING_STARTS_WITH"] = "sw"
      m["MESSAGE_MATCHER_STRING_ENDS_WITH"] = "ew"
      m["MESSAGE_MATCHER_STRING_EXISTS"] = "ex"
      m["MESSAGE_MATCHER_STRING_NOT_EXISTS"] = "nx"
      
      m["MESSAGE_MATCHER_HANDLER"] = invalid
      m.messageMatcherWithJsonObject(dictionary)
    End Function,
    _initMatchers:Function() As Void
      
    End Function,
    messageMatcherWithJsonObject: Function(dictionary as Object) As Void
      matcherString = ""
      if dictionary[m.MESSAGE_JSON_MATCHES] <> invalid AND dictionary[m.MESSAGE_JSON_MATCHES].toStr() <> ""
        _adb_logger().debug("Messages - message matcher type found " + dictionary[m.MESSAGE_JSON_MATCHES])
        matcherString = dictionary[m.MESSAGE_JSON_MATCHES].toStr()
      else
        _adb_logger().warning("Messages - message matcher type is required. Setting to default unknown")
      endif
      matcherHandler = m.matcherHandlerForMatcherString(matcherString)
      
      jsonKeyStr = dictionary[m.MESSAGE_JSON_KEY]
      if jsonKeyStr <> invalid AND jsonKeyStr.Len() > 0
        matcherHandler.key = LCase(dictionary[m.MESSAGE_JSON_KEY].toStr())
      else
        _adb_logger().warning("Messages - error creating matcher, key is empty or null")
        return
      endif
      jsonValuesArray = dictionary[m.MESSAGE_JSON_VALUES]
      if jsonValuesArray <> invalid AND jsonValuesArray.count() > 0
        matcherHandler.setValues(jsonValuesArray)
      end if
      m["MESSAGE_MATCHER_HANDLER"] = matcherHandler
    End Function,
    matcherHandlerForMatcherString: Function(matcherString as String) As Object
      if matcherString = m.MESSAGE_MATCHER_STRING_EQUALS
        return _adb_message_matcher_equals()
      else if matcherString = m.MESSAGE_MATCHER_STRING_NOT_EQUALS
        return _adb_message_matcher_notEquals()
      else if matcherString = m.MESSAGE_MATCHER_STRING_LESS_THAN
        return _adb_message_matcher_lessThan()
      else if matcherString = m.MESSAGE_MATCHER_STRING_LESS_THAN_OR_EQUALS
        return _adb_message_matcher_lessThanEqualTo()
      else if matcherString = m.MESSAGE_MATCHER_STRING_GREATER_THAN
        return _adb_message_matcher_greaterThan()
      else if matcherString = m.MESSAGE_MATCHER_STRING_GREATER_THAN_OR_EQUALS
        return _adb_message_matcher_greaterThanEqualTo()
      else if matcherString = m.MESSAGE_MATCHER_STRING_CONTAINS
        return _adb_message_matcher_contains()
      else if matcherString = m.MESSAGE_MATCHER_STRING_NOT_CONTAINS
        return _adb_message_matcher_notContains()
      else if matcherString = m.MESSAGE_MATCHER_STRING_STARTS_WITH
        return _adb_message_matcher_startsWith()
      else if matcherString = m.MESSAGE_MATCHER_STRING_ENDS_WITH
        return _adb_message_matcher_endsWith()
      else if matcherString = m.MESSAGE_MATCHER_STRING_EXISTS
        return _adb_message_matcher_exists()
      else if matcherString = m.MESSAGE_MATCHER_STRING_NOT_EXISTS
        return _adb_message_matcher_notExists()
      else 
        return _adb_message_matcher_unknown()
      endif
    End Function,
    matchesInMaps: Function(vars As Object, cData As Object) As Boolean
      handler = m["MESSAGE_MATCHER_HANDLER"]
      if handler <> invalid
        maps = {}
        maps.append(vars)
        maps.append(cData)
        matchKey = handler["key"]
        matchKeyStr = matchKey.toStr()
        value = maps.LookupCI(matchKeyStr)
        return handler.matches(value)
      endif
      return false
    End Function
  }
  instance._init(dictionary)
  return instance
End Function

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
Function _adb_message_matcher_contains() As Object
  instance = {
    _init: Function() As Void
      m["key"] = ""
      m["values"] = invalid
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      if jsonValuesArray <> invalid
        m["values"] = jsonValuesArray
      endif
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      if (NOT _adb_message_helper().isString(expectedValue)) AND (NOT _adb_message_helper().isNumber(expectedValue))
        return false
      endif
      
      expectedValueStr = _adb_message_helper().toString(expectedValue)
      
      values = m["values"]
      for each potentialValue in values
        if _adb_message_helper().isString(potentialValue)
          instringIndex = expectedValueStr.Instr(potentialValue)
          if instringIndex <> -1
            return true
          endif
        endif
      end for
      return false
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_endsWith() As Object
  instance = {
    _init: Function() As Void
      m["key"] = ""
      m["values"] = invalid
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      if jsonValuesArray <> invalid
        m["values"] = jsonValuesArray
      endif			
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      if (NOT _adb_message_helper().isString(expectedValue)) AND (NOT _adb_message_helper().isNumber(expectedValue))
        return false
      endif
      expectedValueStr = _adb_message_helper().toString(expectedValue)
      values = m["values"]
      for each potentialValue in values
        if _adb_message_helper().isString(potentialValue)
          if m.stringEndsWith(potentialValue, expectedValueStr) = true
            return true
          endif
        endif
      end for
      return false
    End Function,
    stringEndsWith: Function(suffix, searchString) As Boolean
      instringIndex = searchString.Instr(suffix)
      if instringIndex <> -1
        endStringIndex = instringIndex + suffix.Len() - 1
        if endStringIndex = searchString.Len() - 1
          return true
        endif
      endif
      return false
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_equals() As Object
  instance = {
    _init: Function() As Void
      m["key"] = ""
      m["values"] = invalid
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      if jsonValuesArray <> invalid
        m["values"] = jsonValuesArray
      endif			
    End Function,
    matches: Function(expectedValue As Object) As Boolean			
      if (NOT _adb_message_helper().isString(expectedValue)) AND (NOT _adb_message_helper().isNumber(expectedValue))
        return false
      endif
      expectedValueStr = _adb_message_helper().toString(expectedValue)
      values = m["values"]
      for each potentialValue in values
        potentialValueStr = _adb_message_helper().toString(potentialValue)
        if potentialValueStr = expectedValueStr
          return true
        endif
      end for
      return false
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_exists() As Object
  instance = {
    _init: Function() As Void
      m["key"] = ""
      m["values"] = invalid
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      if jsonValuesArray <> invalid
        m["values"] = jsonValuesArray
      endif			
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      if expectedValue = invalid
        return false
      endif	
      return true	
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_greaterThan() As Object
  
  instance = {
    
    _init: Function() As Void
      m["key"] = ""
      m["values"] = invalid
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      if jsonValuesArray <> invalid
        m["values"] = jsonValuesArray
      endif			
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      expectedValueAsNumber = _adb_message_helper().tryParseNumber(expectedValue)
      if expectedValueAsNumber = invalid
        return false
      endif
      values = m["values"]
      for each potentialValue in values
        if _adb_message_helper().isNumber(potentialValue) AND expectedValueAsNumber > potentialValue
          return true
        endif
      end for
      return false
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_greaterThanEqualTo() As Object
    
  instance = {
    _init: Function() As Void
      m["key"] = ""
      m["values"] = invalid
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      if jsonValuesArray <> invalid
        m["values"] = jsonValuesArray
      endif			
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      expectedValueAsNumber = _adb_message_helper().tryParseNumber(expectedValue)
      if expectedValueAsNumber = invalid
        return false
      endif
      values = m["values"]
      for each potentialValue in values
        if _adb_message_helper().isNumber(potentialValue) AND expectedValueAsNumber >= potentialValue
          return true
        endif
      end for
      return false
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_lessThan() As Object
  instance = {
    _init: Function() As Void
      m["key"] = ""
      m["values"] = invalid
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      if jsonValuesArray <> invalid
        m["values"] = jsonValuesArray
      endif			
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      expectedValueAsNumber = _adb_message_helper().tryParseNumber(expectedValue)
      if expectedValueAsNumber = invalid
        return false
      endif
      values = m["values"]
      for each potentialValue in values
        if _adb_message_helper().isNumber(potentialValue) AND expectedValueAsNumber < potentialValue
          return true
        endif
      end for
      return false
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_lessThanEqualTo() As Object
  
  instance = {
    _init: Function() As Void
      m["key"] = ""
      m["values"] = invalid
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      if jsonValuesArray <> invalid
        m["values"] = jsonValuesArray
      endif			
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      expectedValueAsNumber = _adb_message_helper().tryParseNumber(expectedValue)
      if expectedValueAsNumber = invalid
        return false
      endif
      values = m["values"]
      for each potentialValue in values
        if _adb_message_helper().isNumber(potentialValue) AND expectedValueAsNumber <= potentialValue
          return true
        endif
      end for
      return false
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_notContains() As Object
  instance = {
    _init: Function() As Void
      m["containsHandler"] = _adb_message_matcher_contains()
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      m["containsHandler"].setValues(jsonValuesArray)
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      return NOT m["containsHandler"].matches(expectedValue)
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_notEquals() As Object
  instance = {
    _init: Function() As Void
      m["equalsHandler"] = _adb_message_matcher_equals()
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      m["equalsHandler"].setValues(jsonValuesArray)
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      return NOT m["equalsHandler"].matches(expectedValue)
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_notExists() As Object
  instance = {
    _init: Function() As Void
      m["existsHandler"] = _adb_message_matcher_exists()
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      m["existsHandler"].setValues(jsonValuesArray)
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      return NOT m["existsHandler"].matches(expectedValue)
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_startsWith() As Object
  instance = {
    _init: Function() As Void
      m["key"] = ""
      m["values"] = invalid
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      if jsonValuesArray <> invalid
        m["values"] = jsonValuesArray
      endif
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      if (NOT _adb_message_helper().isString(expectedValue)) AND (NOT _adb_message_helper().isNumber(expectedValue))
        return false
      endif
      expectedValueStr = _adb_message_helper().toString(expectedValue)
      values = m["values"]
      for each potentialValue in values
        if _adb_message_helper().isString(potentialValue)
          if m.stringStartsWith(potentialValue, expectedValueStr) = true
            return true
          endif
        endif
      end for
      return false
    End Function,
    stringStartsWith: Function(prefix, searchString) As Boolean
      instringIndex = searchString.Instr(prefix)
      if instringIndex = 0
        return true
      endif
      return false
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_message_matcher_unknown() As Object
  instance = {
    _init: Function() As Void
      m["key"] = ""
      m["values"] = invalid
    End Function,
    setValues: Function(jsonValuesArray As Object) As Void
      if jsonValuesArray <> invalid
        m["values"] = jsonValuesArray
      endif
      
    End Function,
    matches: Function(expectedValue As Object) As Boolean
      return false
    End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_messages() As Object
  if GetGlobalAA()._adb_messages = invalid
    instance = {
      _init: Function() As Void
        m["MESSAGE_TYPE"] = "type"
        m["callbackMessages"] = invalid
      End Function,
      setMessages: Function(messages as Object) as Void
        if messages <> invalid AND messages.count() > 0
          tempCallbackMessages = []
          for each msg in messages
            msgObject = _adb_message(msg)
            if msgObject <> invalid
              if msgObject[m.MESSAGE_TYPE] = "callback"
                tempCallbackMessages.Push(msgObject)
              endif
            else
              _adb_logger().debug("Invalid message object.")
            endif
          end for
          m["callbackMessages"] = tempCallbackMessages
        endif
      End Function,
      checkFor3rdPartyCallbacks: Function(vars as Object, cData as Object) As Void
        callbacks = m.callbackMessages
        if callbacks = invalid OR callbacks.count() = 0
          return
        endif
        for each key in vars.keys()
          keyStr = key.toStr()
          if type(keyStr) = "roString" OR type(keyStr) = "String"
            val = vars[keyStr]
          endif
        end for
        lowercaseVars = m.lowercaseKeysForMap(vars)
        lowercaseContextData= m.lowercaseKeysForMap(cData)
        for each key in lowercaseVars.keys()
          keyStr = key.toStr()
          if type(keyStr) = "roString" OR type(keyStr) = "String"
            val = lowercaseVars[keyStr]
          endif
        end for
        for each msg in callbacks
          if msg.shouldShowForVariables(lowercaseVars,lowercaseContextData) = true
            msg.show()
          endif
        end for
      End Function,
      lowercaseKeysForMap: Function(vars As Object) As Object
        if vars = invalid OR vars.count() = 0
          return vars
        endif
        result = {}
        for each key in vars.keys()
          ' ?? Check if this is needed.
          if type(key) = "roString" OR type(key) = "String"
            lcKey = LCase(key)
            val = vars[key]
            if val <> invalid
              result[lcKey] = val
            endif
          endif
        end for
        return result
      End Function
    }
    instance._init()
    GetGlobalAA()["_adb_messages"] = instance
  endif
  return GetGlobalAA()._adb_messages
End Function

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
Function _adb_message_template_callback() As Object
    instance = {
        _init: Function() As Void
        End Function,
        setPayloadObject: Function(messageJson as Object) As Void
        End Function,
        shouldShowForVariables: Function(vars As Object, cData As Object) As Boolean
        End Function,
        putMapForTemplatedTokens: Function(combinedVars)
        End Function
      }
    instance._init()
    return instance
End Function

' *************************************************************************
' *
' * ADOBE CONFIDENTIAL
' * ___________________
' *
' *  Copyright 2018 Adobe Systems Incorporated
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
Function _adb_message_worker() as Object
  if GetGlobalAA()._adb_message_worker = invalid
    instance = {
      sendCallback: Function(expandedURL As Dynamic, expandedBody As Dynamic) As Void
        if ADBMobile().getPrivacyStatus() = ADBMobile().PRIVACY_STATUS_OPT_IN
          newHit = {url : expandedURL,  body : expandedBody}
          _adb_logger().debug("Messaging - Queued Hit (" + expandedURL + ")")
          m._queue.Push(newHit)
          m._sendNextHit()
        end if
      End Function,
      processMessage: Function() As Void
        ''' process this message if it's something we need to handle
        msg = wait(1, m._port)
        if type(msg) = "roUrlEvent" AND msg.GetSourceIdentity() = m._http.GetIdentity()
          responseCode = msg.GetResponseCode()
          if responseCode = 200
            _adb_logger().debug("Messaging - Successfully sent hit (" + m._currentHit.url + ")")
          else
            _adb_logger().error("Messaging - Unable to send hit (" + msg.GetFailureReason() + ")")
          end if
          m._currentHit = invalid
          m._sendNextHit()
        end if
      End Function,
      _init: Function() as Void
        m["_http"] = CreateObject("roUrlTransfer")
        m["_port"] = CreateObject("roMessagePort")
        m["_queue"] = []
        m["_currentHit"] = invalid
        ''' configure
        m._http.SetMessagePort(m._port)
        m._http.SetCertificatesFile("common:/certs/ca-bundle.crt")
      End Function,
      _sendNextHit: Function() as Void
        if m._queue.count() > 0 AND m._currentHit = invalid
          ''' grab oldest hit in the queue
          m._currentHit = m._queue.Shift()
          m._http.SetUrl(m._currentHit.url)
          if m._currentHit.body <> invalid AND m._currentHit.body <> ""
            m._http.SetRequest("POST")
            m._http.AsyncPostFromString(expandedBody.toStr())
          else
            m._http.SetRequest("GET")
            m._http.AsyncGetToString()
          end if
        end if
      End Function,
      _clearHits: Function() as Void
        m._queue.Clear()
      End Function
    }
    instance._init()
    GetGlobalAA()["_adb_message_worker"] = instance
  end if
  return GetGlobalAA()._adb_message_worker
End Function

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
Function _adb_aid() as Object
  if GetGlobalAA()._adb_aid = invalid
    instance = {
      _init: Function() as Void
          if ADBMobile().getPrivacyStatus() = ADBMobile().PRIVACY_STATUS_OPT_OUT
            return
          end if
          aid = _adb_persistenceLayer().readValue("aid")
          ignoreAID = _adb_persistenceLayer().readValue("ignoreAid")
          if aid = invalid AND ignoreAID = invalid
            ''' attempt to retrieve AID from analytics
            aid = m._retrieveremoteAID()
            if aid <> invalid
                _adb_persistenceLayer().writeValue("aid", aid)
            else
              ''' no aid to save, write the ignore value
              _adb_persistenceLayer().writeValue("ignoreAid", "true")
            endif
          endif
          ''' save our local copy (to whatever it is, could be invalid)
          m["aid"] = aid
          ''' perform id sync if needed.
          m._syncAIDIfNeeded()
        End Function,
      ''' syncs the recently retrieved AID to visitor id service
      _syncAIDIfNeeded: Function() as Void
          if m["aid"] = invalid
            return
          endif
          ''' we need to sync
          if _adb_persistenceLayer().readValue("aid_synced") = invalid AND _adb_config().visitorIDServiceEnabled() = true
            syncPacket = {}
            syncPacket["AVID"] = m["aid"]
            _adb_visitor().idSync(syncPacket)
            _adb_persistenceLayer().writeValue("aid_synced", "true")
          endif
        End Function,
      _retrieveRemoteAID: Function() as Dynamic
          ''' fast out if analytics is disabled
          if _adb_config().analyticsEnabled() = false
            return invalid
          end if
          url = ""
          if _adb_config().ssl = true
            url = "https"
          else
            url = "http"
          endif
          url = url + "://" + _adb_config().trackingServer + "/id" + _adb_visitor().analyticsIDRequestParameterString()
          ''' TODO: handle visitor ID service addition here
          mp = CreateObject("roMessagePort")
          http = CreateObject("roUrlTransfer")
          http.SetMessagePort(mp)
          http.SetUrl(url)
          http.SetCertificatesFile("common:/certs/ca-bundle.crt")
          http.SetRequest("GET")
          
          success = http.AsyncGetToString()
          identifier = invalid
          if success = true
            response = wait(500, mp)
            if type(response) = "roUrlEvent" AND response.GetResponseCode() = 200
              responseString = response.GetString()
              jsonResponse = ParseJson(responseString)
              if jsonResponse <> invalid
                identifier = jsonResponse["id"]
              endif
            endif
          endif
          ''' if we don't have an identifier and visitor id service is enabled, we're not going to generate one
          if identifier = invalid AND _adb_config().visitorIDServiceEnabled() = true
            return invalid
          endif
          ''' if we get here, we need to generate an id
          if identifier = invalid
            identifier = m._generateLocalAID()
          endif
          return identifier
        End Function,
      _generateLocalAID: Function() as String
          uuid = CreateObject("roDeviceInfo").GetRandomUUID()
          dashRegex = CreateObject("roRegex", "[\-]", "i")
          uuid = UCase(dashRegex.ReplaceAll(uuid, ""))
          HI_ALLOWED_CHARS = ["0", "1", "2", "3", "4", "5", "6", "7"]
          LO_ALLOWED_CHARS = ["0", "1", "2", "3"]
          first16 = HI_ALLOWED_CHARS[Rnd(8) - 1] + Right(Left(uuid, 16), 15)
          last16 = LO_ALLOWED_CHARS[Rnd(4) - 1] + Right(uuid, 15)
          return first16 + "-" + last16
        End Function
        _purgeAID: Function() as Void
          m["aid"] = invalid
          _adb_persistenceLayer().removeValue("aid")
          _adb_persistenceLayer().removeValue("aid_synced")
          _adb_persistenceLayer().removeValue("ignoreAid")
        End Function
    }
    instance._init()
    GetGlobalAA()["_adb_aid"] = instance
  endif
  return GetGlobalAA()._adb_aid
End Function

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
Function _adb_config() as Object
  if GetGlobalAA()._adb_config = invalid
    instance = {
      ''' shared
      version: "4.0.0",
      debugEnabled: false,
      ''' Analytics
      userIdentifier: invalid,
      reportSuiteIDs: invalid,
      trackingServer: invalid,
      characterSet: "UTF-8",
      ssl: false,
      offlineTrackingEnabled: false,
      lifecycleTimeout: 300,
      privacyDefault: "optedin",
      ''' Audience Manager
      aamServer: invalid,
      aamAnalyticsForwardingEnabled: false,
      ''' marketing cloud
      marketingCloudOrganizationIdentifier: invalid,
      visitorIDServiceEnabled: false,
      mcServer: "dpm.demdex.net"
      ''' Media Heartbeat
      mHeartbeatConfigUrl: invalid,
      mTrackingServer: invalid,
      mPublisher: invalid,
      mChannel: invalid,
      mPlayerName: invalid,
      mSSL: false,
      ovp: invalid,
      mSdk: invalid,
      _config: invalid,
      ''' internal private
      _parseConfig: Function() As Object
        fs = CreateObject("roFileSystem")
        if fs.exists("tmp:/ADBMobileConfig.json")
          tempConfig = ReadAsciiFile("tmp:/ADBMobileConfig.json")
          if tempConfig <> invalid AND tempConfig <> ""
            return ParseJson(tempConfig)
          endif
        endif
        return ParseJson(ReadAsciiFile("pkg:/ADBMobileConfig.json"))
      End Function,
      _init: Function() as Void
          m["_config"] =  m._parseConfig()
          ''' read user identifier
          m["userIdentifier"] = _adb_persistenceLayer().readValue("vid")
          if m.userIdentifier <> invalid
            _adb_logger().debug("Config - Found custom visitor id(" + m.userIdentifier + ")")
          endif
          ''' need to make sure we have a valid config object
          if m._config = invalid
            _adb_logger().error("Config - Unable to read config file from pkg:/ADBMobileConfig.json")
            return
          endif
          ''' analytics data
          if m._config.analytics <> invalid
            if m._config.analytics.offlineEnabled <> invalid
              m["offlineTrackingEnabled"] = m._config.analytics.offlineEnabled
            endif
            if m._config.analytics.rsids <> invalid
              m["reportSuiteIDs"] = m._config.analytics.rsids
            endif
            if m._config.analytics.server <> invalid
              m["trackingServer"] = m._config.analytics.server
            endif
            if m._config.analytics.ssl <> invalid
              m["ssl"] = m._config.analytics.ssl
            endif
            if m._config.analytics.lifecycleTimeout <> invalid
              m["lifecycleTimeout"] = m._config.analytics.lifecycleTimeout
            endif
            if m._config.analytics.privacyDefault <> invalid
              m["privacyDefault"] = m._config.analytics.privacyDefault
            endif
          endif
          if m.reportSuiteIDs <> invalid AND m.trackingServer <> invalid
            _adb_logger().debug("Config - Analytics Enabled")
          else
            _adb_logger().debug("Config - Analytics Disabled")
          endif
          ''' audience manager
          if m._config.audienceManager <> invalid
            if m._config.audienceManager.server <> invalid AND m._config.audienceManager.server <> ""
              m["aamServer"] = m._config.audienceManager.server
            endif
            if m._config.audienceManager.analyticsForwardingEnabled <> invalid
              m["aamAnalyticsForwardingEnabled"] = m._config.audienceManager.analyticsForwardingEnabled
            endif
          endif
          if m.aamServer <> invalid
            _adb_logger().debug("Config - Audience Manager Enabled")
          else
            _adb_logger().debug("Config - Audience Manager Disabled")
          endif
          ''' marketing cloud data
          if m._config.marketingCloud <> invalid
            if m._config.marketingCloud.org <> invalid
              m["marketingCloudOrganizationIdentifier"] = m._config.marketingCloud.org
            endif
            if m._config.marketingCloud.server <> invalid AND m._config.marketingCloud.server.Len() > 0
              m["mcServer"] = m._config.marketingCloud.server
            else
              _adb_logger().debug("Config - Visitor ID Service custom endpoint not found in config, using default endpoint.")
            endif
          endif
          ''' remote urls
          remotes = m._config.remotes
          messageObjects = invalid
          if remotes <> invalid
            if remotes.messages <> invalid
              msgURL = remotes.messages
              remoteMsgObjects = m.remoteMessages(msgURL)
              if remoteMsgObjects <> invalid
                messageObjects = ParseJson(remoteMsgObjects)
              endif
            endif
          endif
          ''' local messages
          if messageObjects = invalid
            messageObjects = m._config.messages
          endif
          'Update the messages module
          _adb_messages().setMessages(messageObjects)
          ''' media heartbeat data
          ''' remove the media heartbeat from error state if set during previous app session
          if _adb_media_isInErrorState()
            _adb_logger().debug("Config - Media Heartbeat clearing error state.")
            _adb_media_setErrorState(false)
          endif
          if m._config.mediaHeartbeat <> invalid
            m.configureMediaHeartbeat(m._config.mediaHeartbeat)
          else
            _adb_logger().warning("Config - Media Heartbeat config missing in JSON.")
            _adb_media_setErrorState(true)
          endif
          if m._config.remotes <> invalid and m._config.remotes.mediaHeartbeat <> invalid
            mHeartbeatConfigUrl = m._config.remotes.mediaHeartbeat
            _adb_logger().debug("Config - Fetching media heartbeat config form JSON Url: " + mHeartbeatConfigUrl)
            ' Todo: change this to an async call in future
            url_object = CreateObject("roUrlTransfer")
            url_object.SetCertificatesFile("common:/certs/ca-bundle.crt")
            url_object.setUrl(mHeartbeatConfigUrl)
            config_response = url_object.GetToString()
            if config_response <> invalid
              media_config_json = ParseJson(config_response)
              m.configureMediaHeartbeat(media_config_json)
              _adb_media_setErrorState(false)
            endif
          endif
          ''' log status
          if m.visitorIDServiceEnabled() = true
            _adb_logger().debug("Config - Visitor ID Service Enabled")
          else
            _adb_logger().debug("Config - Visitor ID Service Disabled")
          endif
        End Function,
      visitorIDServiceEnabled: Function() as Boolean
          return m.marketingCloudOrganizationIdentifier <> invalid AND Len(m.marketingCloudOrganizationIdentifier) > 0
        End Function,
      analyticsEnabled: Function() as Boolean
          return m.trackingServer <> invalid AND m.reportSuiteIDs <> invalid
        End Function,
      audienceManagerEnabled: Function() as Boolean
          return m.aamServer <> invalid AND Len(m.aamServer) > 0
        End Function,
      getAnalyticsResponseType: Function() as Integer
          if m.aamAnalyticsForwardingEnabled = true
            return 10
          else
            return 0
          endif
        End Function,
      setUserIdentifier: Function(id as Dynamic) as Void
          if ADBMobile().getPrivacyStatus() <> ADBMobile().PRIVACY_STATUS_OPT_OUT
            m["userIdentifier"] = id
            _adb_persistenceLayer().writeValue("vid", id)
          endif
        End Function,
      purgeUserIdentifier: Function() as Void
          m["userIdentifier"] = invalid
          _adb_persistenceLayer().removeValue("vid")
      End Function,
      configureMediaHeartbeat: Function(mediaConfig as Dynamic) as Void
          if mediaConfig <> invalid
            if mediaConfig.server <> invalid
              m["mTrackingServer"] = mediaConfig.server
            endif
            if mediaConfig.publisher <> invalid
              m["mPublisher"] = mediaConfig.publisher
            endif
            if mediaConfig.channel <> invalid
              m["mChannel"] = mediaConfig.channel
            endif
            if mediaConfig.ovp <> invalid
              m["ovp"] = mediaConfig.ovp
            endif
            if mediaConfig.sdkVersion <> invalid
              m["mSdk"] = mediaConfig.sdkVersion
            endif
            if mediaConfig.ssl <> invalid
              m["mSSL"] = mediaConfig.ssl
            endif
            if mediaConfig.playerName <> invalid
              m["mPlayerName"] = mediaConfig.playerName
            endif
          else
            _adb_logger().debug("Config - Invalid media config object.")
          endif
          ' basic check to see if config was set
          if m.mTrackingServer <> invalid AND m.mPublisher <> invalid AND m.analyticsEnabled()
            _adb_logger().debug("Config - Media Heartbeat Enabled")
          else
            _adb_logger().debug("Config - Media Heartbeat Disabled")
            _adb_media_setErrorState(true)
          endif
        End Function,
      remoteMessages: Function(msgURL as Object) as Object
        if msgURL <> invalid AND msgURL.toStr().Len() > 0
            url_object = CreateObject("roUrlTransfer")
            url_object.SetCertificatesFile("common:/certs/ca-bundle.crt")
            url_object.setUrl(msgURL)
            messages_response = url_object.GetToString()
            if messages_response <> invalid
              messages_json = ParseJson(messages_response)
              if messages_json <> invalid
                messagesObject = FormatJson(messages_json.messages)
                if messagesObject <> invalid
                  return messagesObject
                endif
              endif
            endif
        endif
        return invalid
      End Function
    }
    instance._init()
    GetGlobalAA()["_adb_config"] = instance
  endif
  return GetGlobalAA()._adb_config
End Function

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
Function _adb_identities() as Object
  if GetGlobalAA()._adb_identities = invalid
    instance = {
    _init: Function() As Void
    End Function,
      _getAllIdentifiers: Function() as String
          result = {}
          companyContexts = m._getCompanyContexts()
          if companyContexts <> invalid
            result["companyContexts"] = companyContexts
          endif
          userIds = []
          mcid = m._getMcid()
          if mcid <> invalid
            userIds.Push(mcid)
          endif
          aid = m._getAid()
          if aid <> invalid
            userIds.Push(aid)
          endif
          vid = m._getVid()
          if vid <> invalid
            userIds.Push(vid)
          endif
          uuid = m._getUuid()
          if uuid <> invalid
            userIds.Push(uuid)
          endif
          dsids = m._getDsids()
          if dsids <> invalid
            userIds.Push(dsids)
          endif
          customIds = m._getAllCustomIdentifiers()
          if customIds <> invalid
            For each id in customIds
              userIds.Push(id)
            End For
          endif
          if userIds.Count() > 0
            userIdsObject = {"userIDs":userIds}
            users = []
            users.Push(userIdsObject)
            result["users"] = users
          endif
          jsonResultString = FormatJson(result)
          if jsonResultString = invalid
            _adb_logger().debug("Identities - unable to retrieve SDK identities")
            return ""
          else
            return jsonResultString
          endif
        End Function,
        _getMcid: Function() as Object
          '''Unlike other platforms, we don't persist custom ids so we dont need to return them here
          mid = _adb_visitor().marketingCloudID()
          if m._isNonEmptyString(mid) = true
            return{"namespace":"4","value":mid,"type":"namespaceId"}
          endif
          return invalid
        End Function,
        _getAid: Function() as Object
          aid = _adb_aid().aid
          if m._isNonEmptyString(aid) = true
            return{"namespace":"avid","value":aid,"type":"integrationCode"}
          endif
          return invalid
        End Function,
        _getVid: Function() as Object
          vid = _adb_config().userIdentifier
          rsid = _adb_config().reportSuiteIDs
          if (m._isNonEmptyString(rsid) = true and m._isNonEmptyString(vid) = true)
            rsids = rsid.Split(",")
            return{"namespace":"vid","value":vid,"type":"analytics","rsids":rsids}
          endif
          return invalid
        End Function,
        _getUuid: Function() as Object
          uuid = _adb_audienceManager()._getUUID()
          if m._isNonEmptyString(uuid) = true
            return{"namespace":"0","value":uuid,"type":"namespaceId"}
          endif
          return invalid
        End Function,
        _getDsids: Function() as Object
          dpid = _adb_audienceManager().getDpid()
          dpuuid = _adb_audienceManager().getDpuuid()
          if m._isNonEmptyString(dpid) = true And m._isNonEmptyString(dpuuid) = true
            return{"namespace":dpid,"value":dpuuid,"type":"namespaceId"}
          endif
          return invalid
        End Function,
        _getAllCustomIdentifiers: Function() as Object
          syncedIds =  _adb_visitor().getAllSyncedIdentifiers()
          response = []
          if syncedIds <> invalid
            For each idType in syncedIds
              responseObject = {"namespace":idType,"value":syncedIds[idType],"type":"integrationCode"}
              response.Push(responseObject)
            End For
          endif
          return response
        End Function,
        _getCompanyContexts: Function() as Object
          orgId = _adb_config().marketingCloudOrganizationIdentifier
          if m._isNonEmptyString(orgId)
            return[{"namespace":"imsOrgID","value":orgId}]
          endif
          return invalid
        End Function,
        _isNonEmptyString: Function(str as Dynamic) as Boolean
          if str <> invalid and str.Len() > 0
            return true
          end if
          return false
        End Function,
        _resetAnalyticsIdentifiers: Function() as Void
          _adb_aid()._purgeAID()
          _adb_config().purgeUserIdentifier()
        End Function
        _resetAllIdentifiers: Function() as Void
          m._resetAnalyticsIdentifiers()
          _adb_audienceManager()._resetData()
          _adb_audienceManager()._purgeDpidAndDpuuid()
          _adb_visitor().purgeIdentities()
        End Function
    }
    instance._init()
    GetGlobalAA()["_adb_identities"] = instance
  endif
  return GetGlobalAA()._adb_identities
End Function

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
Function _adb_logger() as Object
  if GetGlobalAA()._adb_logger = invalid
    instance = {
      debugLoggingEnabled: false,
      warning: Function(message as String) as Void
          if m.debugLoggingEnabled = true
            print "ADBMobile Warning: " + message
          endif
        End Function,
      error: Function(message as String) as Void
          print "ADBMobile Error: " + message
        End Function,
      debug: Function(message as String) as Void
          if m.debugLoggingEnabled = true
            print "ADBMobile Debug: " + message
          endif
        End Function,
      instanceWithTag: Function(logTag as String) as Object
          instance = {
            _logTag : "[" + logTag + "] ",
            warning: Function(message as String) as Void
                if _adb_logger().debugLoggingEnabled = true
                  _adb_logger().warning(m._logTag + message)
                endif
              End Function,
            error: Function(message as String) as Void
                  _adb_logger().error(m._logTag + message)
              End Function,
            debug: Function(message as String) as Void
                if _adb_logger().debugLoggingEnabled = true
                  _adb_logger().debug(m._logTag + message)
                endif 
              End Function,
          }
          return instance
      End Function
      
    }
    GetGlobalAA()["_adb_logger"] = instance
  endif
  return GetGlobalAA()._adb_logger
End Function

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
Function _adb_media_version() as Object
  if GetGlobalAA()._adb_media_version = invalid
    instance = {
      getVersion: Function() as String
          return m._platform + "-" + ADBMobile().version + "." + m._buildNumber + "-" + m._gitHash
        End Function,
      getApiLevel: Function() as Integer
          return m._api_level
        End Function,
      ''' initialize the private variables
      _init: Function() As Void
          m["_platform"] = "roku"
          m["_buildNumber"] = "11"
          m["_gitHash"] = "513b24"
          m["_api_level"] = 4
        End Function
    }
    instance._init()
    GetGlobalAA()["_adb_media_version"] = instance
  endif
  return GetGlobalAA()._adb_media_version
End Function

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
Function _adb_persistenceLayer() as Object
  if GetGlobalAA()._adb_persistenceLayer = invalid
    instance = {
      ''' private internal variables
      _registry: CreateObject("roRegistrySection", "adbmobile"),
      ''' public Functions
      writeValue: Function(key as String, value as Dynamic) as Dynamic
          m._registry.Write(key, value)
          m._registry.Flush()
        End Function,
      readValue: Function(key as String) as Dynamic
          '''bug in roku - Exists returns true even if no key. value in that case is an empty string
          if m._registry.Exists(key) AND m._registry.Read(key).Len() > 0
            return m._registry.Read(key)
          endif
          return invalid
        End Function,
      removeValue: Function(key as String) as Void
          m._registry.Delete(key)
          m._registry.Flush()
        End Function,
        writeMap: Function(mapName as String, map as Dynamic) as Dynamic
          mapRegistry = CreateObject("roRegistrySection", "adbmobileMap_" + mapName)
          '_adb_logger().debug("Persistence - writeMap() writing to map: adbmobileMap_" + mapName)
          if map <> invalid AND map.Count() > 0
            For each key in map
              if map[key] <> invalid
                '_adb_logger().debug("Persistence - writeMap() writing " + key + ":" + map[key] + " to map: adbmobileMap_" + mapName)
                mapRegistry.Write(key, map[key])
                mapRegistry.Flush()
              End if
            End For
          End if
        End Function,
        readMap: Function(mapName as String) as Dynamic
          mapRegistry = CreateObject("roRegistrySection", "adbmobileMap_" + mapName)
          keyList = mapRegistry.GetKeyList()
          result = {}
          if keyList <> invalid
            '_adb_logger().debug("Persistence - readMap() reading from map: adbmobileMap_" + mapName + " with size:" + keyList.Count().toStr())
            For each key in keyList
              result[key] = mapRegistry.Read(key)
            End For
          End if
          return result
        End Function
        readValueFromMap: Function(mapName as String, key as String) as Dynamic
          mapRegistry = CreateObject("roRegistrySection", "adbmobileMap_" + mapName)
          '_adb_logger().debug("Persistence - readValueFromMap() reading Value for key:" + key + " from map: adbmobileMap_" + mapName)
          if mapRegistry.Exists(key) AND mapRegistry.Read(key).Len() > 0
            return mapRegistry.Read(key)
          endif
          '_adb_logger().debug("Persistence - readValueFromMap() did not get Value for key:" + key + " from map: adbmobileMap_" + mapName)
          return invalid
        End Function,
        removeValueFromMap: Function(mapName as String, key as String) as Void
            mapRegistry = CreateObject("roRegistrySection", "adbmobileMap_" + mapName)
            '_adb_logger().debug("Persistence - removeValueFromMap() removing key:" + key + " from map: adbmobileMap_" + mapName)
            mapRegistry.Delete(key)
            mapRegistry.Flush()
        End Function,
        removeMap: Function(mapName as String) as Void
          mapRegistry = CreateObject("roRegistrySection", "adbmobileMap_" + mapName)
          '_adb_logger().debug("Persistence - removeMap() deleting map: adbmobileMap_" + mapName)
          keyList = mapRegistry.GetKeyList()
          For each key in keyList
            m.removeValueFromMap(mapName, key)
          End For
      End Function
    }
    GetGlobalAA()["_adb_persistenceLayer"] = instance
  endif
  return GetGlobalAA()._adb_persistenceLayer
End Function

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
Function _adb_timer() As Object
  instance = {
    ''' public Functions
    start: Function(interval as Integer, name as String) As Void
        if m._enabled = false
          _adb_logger().debug("[Timer] Starting " + name + " timer with interval (" + interval.ToStr() + ")")
          m._interval = interval
          m._name = name
          m._ts.Mark()
          m._nextTick = m._interval 
          m._enabled = true
        else 
          _adb_logger().debug("[Timer] " + m._name + " timer already started.")
        endif
      End Function,
    stop: Function() As Void
        if m._enabled = true
          _adb_logger().debug("[Timer] Stoping " + m._name + " timer.")
          m._enabled = false
          m._nextTick = invalid
        else 
          _adb_logger().debug("[Timer] " + m._name + " timer already stopped.")
        endif
      End Function,
    restartWithNewInterval: Function(newInterval as Integer) As Void
        _adb_logger().debug("[Timer] Restarting " + m._name + " timer with interval (" + newInterval.ToStr() + ")")
        m._interval = newInterval
        m._ts.Mark()          
        m._nextTick = m._interval 
        m._enabled = true
      End Function,
    reset: Function() As Void        
        _adb_logger().debug("[Timer] Resetting " + m._name)          
        m._ts.Mark()          
        m._nextTick = m._interval
        m._enabled = true         
      End Function,
    ticked: Function() As Boolean
        ticked = false
        milliseconds = m._ts.TotalMilliseconds()
        
        if milliseconds >= m._nextTick
          m._nextTick = milliseconds + m._interval
          ticked = true
        endif
        return ticked
      End Function,
    elapsedTime: Function() As Integer
        return m._ts.TotalMilliseconds()
      End Function,
    enabled: Function() As Boolean
        return m._enabled
      End Function,
    ''' initialize the private variables
    _init: Function() As Void
        m["_ts"] = CreateObject ("roTimespan")
        m["_interval"] = invalid
        m["_name"] = ""
        m["_enabled"] = false
        m["_nextTick"] = invalid
      End Function
  }
  instance._init()
  return instance
End Function

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
Function _adb_util() as Object
  if GetGlobalAA()._adb_util = invalid
    instance = {
      getTimestampInMillis: Function() as String
          dateTime = CreateObject("roDateTime")
          currMS = dateTime.GetMilliseconds()
          timeInSeconds = dateTime.AsSeconds()
          timeInMillis = timeInSeconds.ToStr()
          if currMS > 99
            timeInMillis = timeInMillis + currMS.ToStr()
          else if currMS > 9 AND currMS < 100
            timeInMillis = timeInMillis + "0" + currMS.ToStr()
          else if currMS >= 0 AND currMS < 10
            timeInMillis = timeInMillis + "00" + currMS.ToStr()
          endif
          return timeInMillis
        End Function,
      generateMD5: Function(input As String) As String
          ba = CreateObject("roByteArray")
          ba.FromAsciiString(input)
          digest = CreateObject("roEVPDigest")
          digest.Setup("md5")
          digest.Update(ba)
          return digest.Final()
        End Function,
        generateSHA256: Function(input As String) As String
            ba = CreateObject("roByteArray")
            ba.FromAsciiString(input)
            digest = CreateObject("roEVPDigest")
            digest.Setup("sha256")
            digest.Update(ba)
            return digest.Final()
          End Function,
      generateSessionId: Function() As String
          deviceInfo = CreateObject("roDeviceInfo")
          uuid = deviceInfo.GetRandomUUID()
          currTime = m.getTimestampInMillis()
          mid = _adb_visitor().marketingCloudID()
          if mid = invalid
              mid = ""
          end if
          hashedMidUuid = m.generateSHA256(mid+uuid)
          result$ = currTime + hashedMidUuid
          return result$
        End Function,
      calculateTimeDiffInMillis: Function(ts1 As String, ts2 As String) As Integer
          result% = Mid(ts1, 5).ToInt() - Mid(ts2, 5).ToInt()
          return result%
        End Function,
      decodeBase64String: Function(encodedString As String) As Object
        ba=CreateObject("roByteArray")
        ba.FromBase64String(encodedString)
        return ba.ToAsciiString()
      End Function
    }
    GetGlobalAA()["_adb_util"] = instance
  endif
  return GetGlobalAA()._adb_util
End Function

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
Function _adb_visitor() as Object
  if GetGlobalAA()._adb_visitor = invalid
    instance = {
      ''' private vars
      _mid: _adb_persistenceLayer().readValue("visitor_mid"),
      _blob: _adb_persistenceLayer().readValue("visitor_blob"),
      _hint: _adb_persistenceLayer().readValue("visitor_hint"),
      _ttl: _adb_persistenceLayer().readValue("visitor_ttl"),
      _lastSync: _adb_persistenceLayer().readValue("visitor_sync"),
      _urlEncoder: CreateObject("roUrlTransfer"),
      ''' constants
      ADVERTISING_IDENTIFIER_DSID: "DSID_121963",
      ALL_VISISTOR_SYNCED_IDENTIFIERS_MAP_KEY: "all_visitor_synced_identifiers",
      ''' init Function
      _init: Function() as Void
          m._allIdentifiers = _adb_persistenceLayer().readMap(m.ALL_VISISTOR_SYNCED_IDENTIFIERS_MAP_KEY)
          m._adID = _adb_persistenceLayer().readValueFromMap(m.ALL_VISISTOR_SYNCED_IDENTIFIERS_MAP_KEY, m.ADVERTISING_IDENTIFIER_DSID)
          if m._lastSync = invalid : m._lastSync = "0" : endif
          if m._ttl = invalid : m._ttl = "0" : endif
          if m._allIdentifiers = invalid : m._allIdentifiers = {} : endif
          if m._adID = invalid : m._adID = "" : endif
          m.idSync({})
        End Function,
      ''' private methods
      ''' saves the given key/value to persistent storage
      ''' auto converts value to string, if value is invalid the key will be removed.
      _saveIfValid: Function(key as string, value as dynamic) as Void
          if value <> invalid
            if type(value) = "Integer" OR type(value) = "roInteger" OR type(value) = "roInt"
              value = value.ToStr()
            endif
            _adb_persistenceLayer().writeValue(key, value)
          else
            _adb_persistenceLayer().removeValue(key)
          endif
        End Function,
      _saveMapIfValid: Function(map as Dynamic) as void
        if map <> invalid
          _adb_persistenceLayer().writeMap(m.ALL_VISISTOR_SYNCED_IDENTIFIERS_MAP_KEY, map)
        End if
      End Function,
      ''' generate 63 bit random integer as a strong (64 bit signed positive only)
      _makeRandInt: Function() as String
          ''' ensure that we don't get 9 as a starting value, which could make an out of bounds int
          padVal = Rnd(9) - 1
          returnVal = padVal.ToStr()
          for i = 1 to 18
            newval = Rnd(10) - 1
            returnVal = returnVal + newval.ToStr()
          end for
          return returnVal
        End Function,
      ''' generates a marketing cloud visitor id locally
      _generateLocalMid: Function() as String
          return m._makeRandInt() + m._makeRandInt()
        End Function,
      ''' public methods
      setAdvertisingIdentifier: Function(adIdentifier as String) as void
        if (m._adID <> adIdentifier)
          m._adID = adIdentifier
          adIDSyncObject = {}
          adIDSyncObject[m.ADVERTISING_IDENTIFIER_DSID] =  m._adID
          _adb_logger().debug("ID Service - setAdvertisingIdentifier() setting advertisingIdentifier=" + m._adId)
          m.idSync(adIDSyncObject)
        else
          _adb_logger().debug("ID Service - setAdvertisingIdentifier() not setting advertisingIdentifier:" + m._adId + " as it is already persisted on the device")
        end if
      End Function,
      ''' performs an identifier sync
      idSync: Function(identifiers as Dynamic) as Void
          ''' fail fast if we're not provisioned for visitor id service
          if _adb_config().visitorIDServiceEnabled() = false
            _adb_logger().debug("ID Service - not Enabled.")
            return
          endif
          ''' fail if privacy is opt_out?
          if ADBMobile().getPrivacyStatus() <> ADBMobile().PRIVACY_STATUS_OPT_IN
            _adb_logger().debug("ID Service - Privacy status is not set to opt in, no id sync will be submitted.")
            return
          endif
          ''' get org id
          orgId = _adb_config().marketingCloudOrganizationIdentifier
          url = ""
          if _adb_config().ssl = true
            url = "https"
          else
            url = "http"
          endif
          url = url + "://" + _adb_config().mcServer + "/id?d_rtbd=json&d_ver=2&d_orgid=" + orgId
          ''' apply url parameters
          if m._blob <> invalid
            url = url + _adb_urlEncoder()._serializeKeyValuePair("d_blob", m._blob)
          endif
          if m._mid <> invalid
            url = url + _adb_urlEncoder()._serializeKeyValuePair("d_mid", m._mid)
          endif
          if m._hint <> invalid
            url = url + _adb_urlEncoder()._serializeKeyValuePair("dcs_region", m._hint)
          endif
          ''' append identifiers
          doSendSyncRequest = false
          if identifiers <> invalid AND identifiers.Count() > 0
            for each key in identifiers
              if key <> invalid AND key <> ""
                if identifiers[key] = invalid
                  identifiers[key] = ""
                endif
                if m.doSync(key, identifiers[key])
                  doSendSyncRequest = true
                  url = url + "&d_cid_ic=" + m._urlEncoder.Escape(key) + "%01" + m._urlEncoder.Escape(identifiers[key])
                  m._allIdentifiers[key] = identifiers[key]
                  _adb_logger().debug("ID Service - idSync() Adding Key value for idsync to map {" + key + ":" + identifiers[key] +"}")
                else
                  _adb_logger().debug("ID Service - idSync() Already Synced ID:" + key + " with value:" + identifiers[key])
                endif
              else
                _adb_logger().debug("ID Service - idSync() Invalid Key passed to idsync, will not sync/save")
              endif
            End for
            ''' All IDs already synced, No new IDs to sync so just return
            if Not doSendSyncRequest
              _adb_logger().debug("ID Service - idSync() Already Synced all IDs, so not sending ID Sync request")
              return
            endif
            ''' persist
              _adb_logger().debug("ID Service - idSync() Saving map of Synced IDs to persistence")
              m._saveMapIfValid(m._allIdentifiers)
          End if
          ''' create connection for syncing ids
          mp = CreateObject("roMessagePort")
          http = CreateObject("roUrlTransfer")
          http.setUrl(url)
          http.SetCertificatesFile("common:/certs/ca-bundle.crt")
          http.setRequest("GET")
          http.setMessagePort(mp)
          ''' make the call
          _adb_logger().debug("ID Service - Sending id sync call (" + url + ")")
          success = http.AsyncGetToString()
          if success = false
            _adb_logger().error("ID Service - Failed to attempt id sync call, url failed to parse")
          endif
          ''' wait for response
          response = wait(500, mp)
          ''' parse response
          responseString = invalid
          if type(response) = "roUrlEvent"
            if response.GetResponseCode() <> 200
              _adb_logger().error("ID Service - Error connecting to service (" + response.GetFailureReason() + ")")
            else
              responseString = response.GetString()
            endif
          endif
          ''' parse json object
          responseObject = invalid
          if responseString <> invalid
            responseObject = ParseJson(responseString)
          endif
          ''' look for identifiers
          if responseObject <> invalid AND responseObject.d_mid <> invalid
            m._mid = responseObject.d_mid
            if responseObject.d_blob <> invalid
              m._blob = responseObject.d_blob
            else
              m._blob = invalid
            endif
            if responseObject.dcs_region <> invalid
              m._hint = responseObject.dcs_region
            else
              m._hint = invalid
            endif
            if responseObject.id_sync_ttl <> invalid
              m._ttl = responseObject.id_sync_ttl.toStr()
            else
              m._ttl = "0"
            endif
          elseif m._mid = invalid
            m._mid = m._generateLocalMid()
            m._blob = invalid
            m._hint = invalid
            m._ttl = "600"
            _adb_logger().debug("ID Service - No response from server, generated local mid(" + m._mid + ")")
          endif
          m._lastSync = CreateObject("roDateTime").AsSeconds().toStr()
          ''' persist
          m._saveIfValid("visitor_mid", m._mid)
          m._saveIfValid("visitor_blob", m._blob)
          m._saveIfValid("visitor_hint", m._hint)
          m._saveIfValid("visitor_ttl", m._ttl)
          m._saveIfValid("visitor_sync", m._lastSync)
        End Function,
        doSync: Function(key as String, value as String) as Boolean
          savedIds = m.getAllSyncedIdentifiers()
          if savedIds <> invalid
            if savedIds[key] <> invalid AND savedIds[key] = value
                return false
            endif
          endif
          return true
        End Function
      ''' Returns all custom Identifiers set using idSync
      getAllSyncedIdentifiers: Function() as Dynamic
        ids = _adb_persistenceLayer().readMap(m.ALL_VISISTOR_SYNCED_IDENTIFIERS_MAP_KEY)
        return ids
      End Function,
      ''' getter Function for marketing cloud id
      marketingCloudID: Function () as Dynamic
          return m._mid
        End Function,
      analyticsIDRequestParameterString: Function () as String
          if m._mid <> invalid
            return "?mid=" + m._mid + "&mcorgid=" + _adb_config().marketingCloudOrganizationIdentifier
          endif
          return ""
        End Function,
      analyticsParameters: Function () as Object
          responseParameters = {}
          if m._mid <> invalid
            responseParameters["mid"] = m._mid
          else
            return responseParameters
          endif
          if m._blob <> invalid
            responseParameters["aamb"] = m._blob
          endif
          if m._hint <> invalid
            responseParameters["aamlh"] = m._hint
          endif
          return responseParameters
        End Function,
      aamParameters: Function () as String
          response = ""
          if m._mid <> invalid
            response = response + _adb_urlEncoder()._serializeKeyValuePair("d_mid", m._mid)
          else
            return response
          endif
          if m._blob <> invalid
            response = response + _adb_urlEncoder()._serializeKeyValuePair("d_blob", m._blob)
          endif
          if m._hint <> invalid
            response = response + _adb_urlEncoder()._serializeKeyValuePair("dcs_region", m._hint)
          endif
          return response
        End Function
      purgeIdentities: Function() as Void
        m._mid = invalid
        _adb_persistenceLayer().removeValue("visitor_mid")
        _adb_persistenceLayer().removeMap(m.ALL_VISISTOR_SYNCED_IDENTIFIERS_MAP_KEY)
      End Function
    }
    instance._init()
    GetGlobalAA()["_adb_visitor"] = instance
  endif
  return GetGlobalAA()._adb_visitor
End Function
