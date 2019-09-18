/*************************************************************************
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2018 Adobe
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe and its suppliers, if any. The intellectual
 * and technical concepts contained herein are proprietary to Adobe
 * and its suppliers and are protected by all applicable intellectual
 * property laws, including trade secret and copyright laws.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe.
 **************************************************************************/

import Foundation
import AVFoundation

class VideoAnalyticsProvider: NSObject, ADBMediaHeartbeatDelegate {
    let PLAYER_NAME = "iOS basic media player"
    let VIDEO_ID    = "bipbop"
    let VIDEO_NAME  = "Bip bop video"
    
    let HEARTBEAT_TRACKING_SERVER    = "obumobile5.hb.omtrdc.net"
    let HEARTBEAT_CHANNEL            = "test-channel"
    let HEARTBEAT_OVP_NAME           = "test-ovp"
    let HEARTBEAT_APP_VERSION        = "MediaSDK 2.x Sample Player(Swift)";
    
    let VIDEO_LENGTH = 1800
    
    let logTag = "#VideoAnalyticsProvider"
    var _mediaHeartbeat: ADBMediaHeartbeat!
    var _playerDelegate: VideoPlayer!
    
    @objc func initWithPlayerDelegate(player: VideoPlayer) {
        _playerDelegate = player
        
        let config = ADBMediaHeartbeatConfig.init()
        config.trackingServer = HEARTBEAT_TRACKING_SERVER
        config.channel = HEARTBEAT_CHANNEL
        config.appVersion = HEARTBEAT_APP_VERSION
        config.ovp = HEARTBEAT_OVP_NAME
        config.playerName = PLAYER_NAME
        config.ssl = true
        config.debugLogging = false
        
        _mediaHeartbeat = ADBMediaHeartbeat.init(delegate: self as ADBMediaHeartbeatDelegate, config: config)
        
        setupPlayerNotifications()
        
    }
    
    deinit{
        destroy()
    }
    
    
    func getQoSObject() -> ADBMediaObject {
        return ADBMediaHeartbeat.createQoSObject(withBitrate: 500000, startupTime: 2, fps: 24, droppedFrames: 10)
    }
    
    func getCurrentPlaybackTime() -> TimeInterval {
        return _playerDelegate.getCurrentPlaybackTime()
    }
    
    func destroy() {
        NotificationCenter.default.removeObserver(self)
        
        _mediaHeartbeat = nil
        _playerDelegate = nil
    }
    
    @objc func onMainVideoLoaded(notification: NSNotification) {
        NSLog("\(logTag) onMainVideoLoaded()")
        let mediaObject = ADBMediaHeartbeat.createMediaObject(withName: VIDEO_NAME, mediaId: VIDEO_ID, length: Double(VIDEO_LENGTH), streamType: ADBMediaHeartbeatStreamTypeVOD, mediaType:ADBMediaType.video)
        
        let standardVideoMetadata = [ADBVideoMetadataKeySHOW: "Sample show",
                                     ADBVideoMetadataKeySEASON: "Sample season"]
        
        mediaObject.setValue(standardVideoMetadata, forKey: ADBMediaObjectKeyStandardMediaMetadata)
        
        let videoMetadata = ["isUserLoggedIn" : "false",
                             "tvStation" : "Sample TV station"]
        
        _mediaHeartbeat.trackSessionStart(mediaObject, data: videoMetadata)
        
    }
    
    
    
    
    @objc func onMainVideoUnloaded(notification: NSNotification)  {
        NSLog("\(logTag) onMainVideoUnloaded()")
        _mediaHeartbeat.trackSessionEnd()
    }
    
    @objc func onPlay(notification: NSNotification)  {
        NSLog("\(logTag) onPlay()")
        _mediaHeartbeat.trackPlay()
    }
    
    @objc func onStop(notification: NSNotification)  {
        NSLog("\(logTag) onStop()")
        _mediaHeartbeat.trackPause()
    }
    
    @objc func onComplete(notification: NSNotification)  {
        NSLog("\(logTag) onComplete()")
        _mediaHeartbeat.trackComplete()
    }
    
    @objc func onSeekStart(notification: NSNotification)  {
        NSLog("\(logTag) onSeekStart()")
        _mediaHeartbeat.trackEvent(ADBMediaHeartbeatEvent.seekStart, mediaObject: nil, data: nil)
    }
    
    @objc func onSeekComplete(notification: NSNotification)  {
        NSLog("\(logTag) onSeekComplete()")
        _mediaHeartbeat.trackEvent(ADBMediaHeartbeatEvent.seekComplete, mediaObject: nil, data: nil)
    }
    
    @objc func onChapterStart(notification: NSNotification)  {
        NSLog("\(logTag) onChapterStart()")
        
        let chapterDictionary = ["segmentType": "Sample segment type"]
        
        var chapterData = notification.userInfo
        
        let chapterObject = ADBMediaHeartbeat.createChapterObject(withName: chapterData!["name"] as! String, position: chapterData!["position"] as! Double, length: chapterData!["length"] as! Double, startTime: chapterData!["time"] as! Double)
        
        
        _mediaHeartbeat.trackEvent(ADBMediaHeartbeatEvent.chapterStart, mediaObject: chapterObject, data: chapterDictionary)
    }
    
    @objc func onChapterComplete(notification: NSNotification)  {
        NSLog("\(logTag) onChapterComplete()")
        _mediaHeartbeat.trackEvent(ADBMediaHeartbeatEvent.chapterComplete, mediaObject: nil, data: nil)
        
    }
    
    @objc func onAdStart(notification: NSNotification)  {
        NSLog("\(logTag) onAdStart()")
        
        let adBreakData = notification.userInfo!["adbreak"] as! [String: Any]
        let adData = notification.userInfo!["ad"] as! [String: Any]
        
        let adBreakObject = ADBMediaHeartbeat.createAdBreakObject(withName: adBreakData["name"] as! String, position: adBreakData["position"] as! Double, startTime: adBreakData["time"] as! Double)
        
        let adObject = ADBMediaHeartbeat.createAdObject(withName: adData["name"] as! String, adId: adData["id"] as! String, position: adData["position"] as! Double, length: adData["length"] as! Double)
        
        let standardAdMetadata = [ADBAdMetadataKeyADVERTISER: "Sample Advertiser",
                                  ADBAdMetadataKeyCAMPAIGN_ID: "Sample Campaign"]
        
        adObject.setValue(standardAdMetadata, forKey: ADBMediaObjectKeyStandardAdMetadata)
        
        let adDictionary = ["affiliate" : "Sample affiliate"]
        
        _mediaHeartbeat.trackEvent(ADBMediaHeartbeatEvent.adBreakStart, mediaObject: adBreakObject, data: nil)
        _mediaHeartbeat.trackEvent(ADBMediaHeartbeatEvent.adStart, mediaObject: adObject, data: adDictionary)
    }
    
    @objc func onAdComplete(notification: NSNotification)  {
        NSLog("\(logTag) onAdComplete()")
        
        _mediaHeartbeat.trackEvent(ADBMediaHeartbeatEvent.adComplete, mediaObject: nil, data: nil)
        _mediaHeartbeat.trackEvent(ADBMediaHeartbeatEvent.adBreakComplete, mediaObject: nil, data: nil)
    }
    
    func setupPlayerNotifications()  {
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onMainVideoLoaded), name: NSNotification.Name(rawValue: PLAYER_EVENT_VIDEO_LOAD), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onMainVideoUnloaded), name: NSNotification.Name(rawValue: PLAYER_EVENT_VIDEO_UNLOAD), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onPlay), name: NSNotification.Name(rawValue: PLAYER_EVENT_PLAY), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onStop), name: NSNotification.Name(rawValue: PLAYER_EVENT_PAUSE), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onSeekStart), name: NSNotification.Name(rawValue: PLAYER_EVENT_SEEK_START), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onSeekComplete), name: NSNotification.Name(rawValue: PLAYER_EVENT_SEEK_COMPLETE), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onComplete), name: NSNotification.Name(rawValue: PLAYER_EVENT_COMPLETE), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onChapterStart), name: NSNotification.Name(rawValue: PLAYER_EVENT_CHAPTER_START), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onChapterComplete), name: NSNotification.Name(rawValue: PLAYER_EVENT_CHAPTER_COMPLETE), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onAdStart), name: NSNotification.Name(rawValue: PLAYER_EVENT_AD_START), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onAdComplete), name: NSNotification.Name(rawValue: PLAYER_EVENT_AD_COMPLETE), object: nil)
        
    }
}

