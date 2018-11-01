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

import UIKit

class ViewController: UIViewController {
    let CONTENT_URL = "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"
    var adLabel: UILabel!
    var videoAnalyticsProvider: VideoAnalyticsProvider?
    var videoPlayer: VideoPlayer!
    
    override func viewDidAppear(_ animated: Bool) {
        ADBMobile.setDebugLogging(true)
        
        if(videoPlayer == nil) {
            videoPlayer = VideoPlayer()
            videoPlayer.loadContentURL(url: URL(string: CONTENT_URL)!)
            createAdLabel()
            renderVideoPlayer()
        }

        if(videoAnalyticsProvider == nil) {
            videoAnalyticsProvider = VideoAnalyticsProvider()
            videoAnalyticsProvider!.initWithPlayerDelegate(player: videoPlayer!)
        }
    }
    
    func createAdLabel() {
        let rect = CGRect(
            origin: CGPoint(x: 40, y: 20),
            size: CGSize.init(width: 200.0, height: 200.0)
        )
        adLabel = UILabel.init(frame: rect)
        adLabel.text = "AD"
        adLabel.isHidden = true
        adLabel.textColor = UIColor.white
    }
    
    func renderVideoPlayer() {
        if(videoPlayer != nil) {
            let playerViewController = videoPlayer.getPlayerViewController()
            // Modally present the player and call the player's play() method when complete.
            self.present(playerViewController, animated: true) {
                self.videoPlayer.play()
                playerViewController.view.addSubview(self.adLabel)
                playerViewController.view.bringSubview(toFront: self.adLabel)
            }
            addNotificationHandlers()
        }
    }
    
    func addNotificationHandlers() {
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onAdStart), name: NSNotification.Name(rawValue: PLAYER_EVENT_AD_START), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoAnalyticsProvider.onAdComplete), name: NSNotification.Name(rawValue: PLAYER_EVENT_AD_COMPLETE), object: nil)
    }
    
    @objc func onAdStart(notification: NSNotification)  {
        adLabel.isHidden = false
    }
    
    @objc func onAdComplete(notification: NSNotification)  {
        adLabel.isHidden = true
    }
    
    @IBAction func OpenVideoView(_ sender: Any) {
        renderVideoPlayer()
    }
    
    func reset() {
        videoPlayer = nil
        videoAnalyticsProvider = nil
    }
    
    deinit {
        reset()
    }
    
    
}

