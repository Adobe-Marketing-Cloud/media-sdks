/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2014 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */

document.addEventListener("DOMContentLoaded", function(event) {

    // Create the VideoPlayer.
    var videoPlayer = new VideoPlayer('movie');

    // Create the AnalyticsProvider instance and attach it to the VideoPlayer instance.
    var analyticsProvider = new VideoAnalyticsProvider(videoPlayer);

    // Setup the ad label.
    NotificationCenter().addEventListener(PlayerEvent.AD_START, onEnterAd);
    NotificationCenter().addEventListener(PlayerEvent.AD_COMPLETE, onExitAd);
    NotificationCenter().addEventListener(PlayerEvent.SEEK_COMPLETE, onSeekComplete);
    NotificationCenter().addEventListener(PlayerEvent.VIDEO_UNLOAD, onExitAd);

    function onEnterAd() {
        var elem = document.getElementById("pub-label");
        elem.style.display = 'block';
    }

    function onExitAd() {
      var elem = document.getElementById("pub-label");
      elem.style.display = 'none';
    }

    function onSeekComplete() {
        if (!videoPlayer.getAdInfo()) {
            // The user seeked outside the ad.
            onExitAd();
        }
    }
});
