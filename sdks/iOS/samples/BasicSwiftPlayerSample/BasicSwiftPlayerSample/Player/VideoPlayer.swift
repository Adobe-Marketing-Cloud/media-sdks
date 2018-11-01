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
import AVKit
import AVFoundation


let PLAYER_EVENT_VIDEO_LOAD = "player_video_load"
let PLAYER_EVENT_VIDEO_UNLOAD = "player_video_unload"
let PLAYER_EVENT_PLAY = "player_play"
let PLAYER_EVENT_PAUSE = "player_pause"
let PLAYER_EVENT_COMPLETE = "player_complete"
let PLAYER_EVENT_SEEK_START = "player_seek_start"
let PLAYER_EVENT_SEEK_COMPLETE = "player_seek_complete"
let PLAYER_EVENT_AD_START = "player_ad_start"
let PLAYER_EVENT_AD_COMPLETE = "player_ad_complete"
let PLAYER_EVENT_CHAPTER_START = "player_chapter_start"
let PLAYER_EVENT_CHAPTER_COMPLETE = "player_chapter_complete"

class VideoPlayer: AVPlayer {
    var _videoLoaded : Bool!
    var _seeking: Bool!
    var _paused: Bool!
    
    var _isInChapter: Bool!
    var _isInAd: Bool!
    var _chapterPosition:Double!
    
    
    let AD_START_POS:Double = 15
    let AD_END_POS:Double = 30
    let AD_LENGTH:Double = 15
    
    let CHAPTER1_START_POS:Double = 0
    let CHAPTER1_END_POS:Double = 15
    let CHAPTER1_LENGTH:Double = 15
    
    let CHAPTER2_START_POS:Double = 30
    let CHAPTER2_LENGTH:Double = 30
    
    let MONITOR_TIMER_INTERVAL = 0.5 // 500 milliseconds
    
    let kStatusKey                = "status"
    let kRateKey                  = "rate"
    let kDurationKey              = "duration"
    let kPlaybackBufferEmpty      = "playbackBufferEmpty"
    let kPlaybackBufferFull       = "playbackBufferFull"
    let kPlaybackLikelyToKeepUp   = "playbackLikelyToKeepUp"
    
    var player: AVPlayer = AVPlayer()
    var playerViewController: AVPlayerViewController = AVPlayerViewController()
    private var VHLMediaPlayerKVOContext = 0
    
    var timer: Timer!
    
    func loadContentURL(url: URL)  {
        
        _videoLoaded = false
        _seeking = false
        _paused = true
        _isInAd = false
        _isInChapter = false
        
        player = AVPlayer(url: url)
        playerViewController.player = player
        
        playerViewController.player!.addObserver(self, forKeyPath: kRateKey, options: [], context: &VHLMediaPlayerKVOContext)
        playerViewController.player!.addObserver(self, forKeyPath: kStatusKey, options: [], context: &VHLMediaPlayerKVOContext)

        NotificationCenter.default.addObserver(self, selector: #selector(onMediaFinishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    func playVideo()  {
        player.play()
    }
    
    func getPlayerViewController() -> AVPlayerViewController {
        return playerViewController
    }
    
    func getCurrentPlaybackTime() -> TimeInterval {
        let time = CMTimeGetSeconds((playerViewController.player!.currentTime()))
        
        return time
    }
    
    func duration() -> Double {
        return CMTimeGetSeconds((playerViewController.player?.currentItem?.duration)!)
    }
    
    deinit {
        if(timer != nil) {
            timer.invalidate()
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func onMediaFinishedPlaying(notification: NSNotification)  {
        NSLog("MediaFinishedPlaying")
        completeVideo()
    }
    
    //getting events from player
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if(context != &VHLMediaPlayerKVOContext) {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
        
        if(keyPath == kStatusKey) {
            if(self.playerViewController.player?.status == AVPlayerStatus.failed) {
                pausePlayback()
            }
        }
        else if(keyPath == kRateKey) {
            if(self.playerViewController.player!.rate == 0.0) {
                pausePlayback()
            }
            else {
                if(_seeking) {
                    NSLog("Stop seeking.")
                    _seeking = false
                    doPostSeekComputations()
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: PLAYER_EVENT_SEEK_COMPLETE), object: self)
                }
                else
                {
                    NSLog("Resume playback.")
                    openVideoIfNecessary()
                    _paused = false
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: PLAYER_EVENT_PLAY), object: self)
                }
            }
        }
    }
    
    //player helper methods
    func openVideoIfNecessary()  {
        
        if (!_videoLoaded)
        {
            resetInternalState()
            startVideo()
            
            // Start the monitor timer.
            timer = Timer.scheduledTimer(timeInterval: MONITOR_TIMER_INTERVAL, target:self, selector: #selector(VideoPlayer.onTimerTick), userInfo: nil, repeats: true)
            
        }
    }
    
    func pauseIfSeekHasNotStarted() ->  Void {
        if (!_seeking)
        {
            pausePlayback()
        }
        else
        {
            NSLog("This pause is caused by a seek operation. Skipping.")
        }
    }
    
    //Call APIs
    func pausePlayback() {
        NSLog("Video paused")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PLAYER_EVENT_PAUSE), object: self)
    }
    
    func startVideo()  {
        // Prepare the video info.
        _videoLoaded = true
        NSLog("Video started")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PLAYER_EVENT_VIDEO_LOAD), object: self)
    }
    
    func completeVideo()  {
        // Complete the second chapter.
        completeChapter()
        NSLog("Video complete")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PLAYER_EVENT_COMPLETE), object: self)
        
        unloadVideo()
    }
    
    func unloadVideo()  {
        NSLog("Video end")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PLAYER_EVENT_VIDEO_UNLOAD), object: self)
        
        if(timer != nil) {
            timer.invalidate()
        }
        resetInternalState()
    }
    
    func resetInternalState()  {
        NSLog("reset")
        _videoLoaded = false
        _seeking = false
        _paused = true
        timer = nil
    }
    
    func startChapter1()  {
        NSLog("start chapter 1")
        _isInChapter = true
        _chapterPosition = 1
        
        let chapterInfo = ["name": "First Chapter",
                           "length": CHAPTER1_LENGTH,
                           "position": _chapterPosition,
                           "time": CHAPTER1_START_POS] as [String : Any]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PLAYER_EVENT_CHAPTER_START), object: self, userInfo: chapterInfo)
    }
    
    func startChapter2()  {
        NSLog("start chapter 2")
        _isInChapter = true
        _chapterPosition = 2
        
        let chapterInfo = ["name": "Second Chapter",
                           "length": CHAPTER2_LENGTH,
                           "position": _chapterPosition,
                           "time": CHAPTER2_START_POS] as [String : Any]
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PLAYER_EVENT_CHAPTER_START), object: self, userInfo: chapterInfo)
    }
    
    func completeChapter()  {
        NSLog("complete chapter")
        _isInChapter = false
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PLAYER_EVENT_CHAPTER_COMPLETE), object: self)
    }
    
    func startAd()  {
        NSLog("start Ad")
        _isInAd = true
        
        let adBreakInfo = ["name": "First AD-Break",
                           "time": AD_START_POS,
                           "position": 1 as Double] as [String : Any]
        
        let adInfo = ["name": "Sample AD",
                      "id": "001",
                      "position": 1 as Double,
                      "length": AD_LENGTH] as [String : Any]
        
        let userInfo = [ "adbreak": adBreakInfo,
                         "ad": adInfo]
        
        // Start the ad.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PLAYER_EVENT_AD_START), object: self, userInfo:userInfo)
    }
    
    func completeAd()  {
        NSLog("complete Ad")
        // Complete the ad.
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: PLAYER_EVENT_AD_COMPLETE), object: self)
        
        // Clear the ad and ad-break info.
        _isInAd = false
    }
    
    //Timeline helper methods
    func doPostSeekComputations()  {
        let vTime = getCurrentPlaybackTime()
        
        // Seek inside the first chapter.
        if (vTime < CHAPTER1_END_POS)
        {
            // If we were not inside the first chapter before, trigger a chapter start
            if (!_isInChapter || _chapterPosition != 1)
            {
                startChapter1()
                
                // If we were in the ad, clear the ad and ad-break info, but don't send the AD_COMPLETE event.
                if (_isInAd)
                {
                    _isInAd = false
                }
            }
        }
            
            // Seek inside ad.
        else if (vTime >= AD_START_POS && vTime < AD_END_POS)
        {
            // If we were not inside the ad before, trigger an ad-start.
            if (!_isInAd)
            {
                startAd()
                
                // Also, clear the chapter info, without sending the CHAPTER_COMPLETE event.
                _isInChapter = false
            }
        }
        else // Seek inside the second chapter.
        {
            // If we were not inside the 2nd chapter before, trigger a chapter start
            if (!_isInChapter || _chapterPosition != 2)
            {
                startChapter2()
                
                // If we were in the ad, clear the ad and ad-break info, but don't send the AD_COMPLETE event.
                if (_isInAd)
                {
                    _isInAd = false
                }
            }
        }
    }
    
    @objc func onTimerTick()  {
        //NSLog("Timer Ticked")
        
        if (_seeking || _paused) {
            return
        }
        
        let vTime = getCurrentPlaybackTime()
        
        // If we are inside the ad content:
        if (vTime >= AD_START_POS && vTime < AD_END_POS) {
            if (_isInChapter) {
                // If for some reason we were inside a chapter, close it.
                completeChapter()
            }
            
            if (!_isInAd) {
                // Start the ad (if not already started).
                startAd()
            }
        }
            
            // Otherwise, we are outside the ad content:
        else
        {
            if (_isInAd)
            {
                // Complete the ad (if needed).
                completeAd()
            }
            
            if (vTime < CHAPTER1_END_POS)
            {
                if (_isInChapter && _chapterPosition != 1)
                {
                    // If we were inside another chapter, complete it.
                    completeChapter()
                }
                
                if (!_isInChapter)
                {
                    // Start the first chapter.
                    startChapter1()
                }
            }
            else
            {
                if (_isInChapter && _chapterPosition != 2)
                {
                    // If we were inside another chapter, complete it.
                    completeChapter()
                }
                
                if (!_isInChapter)
                {
                    // Start the second chapter.
                    startChapter2()
                }
            }
        }
    }
}
