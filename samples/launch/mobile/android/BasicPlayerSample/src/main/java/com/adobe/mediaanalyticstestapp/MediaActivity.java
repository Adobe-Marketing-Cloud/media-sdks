///*************************************************************************
// * ADOBE CONFIDENTIAL
// * ___________________
// *
// * Copyright 2021 Adobe
// * All Rights Reserved.
// *
// * NOTICE: All information contained herein is, and remains
// * the property of Adobe and its suppliers, if any. The intellectual
// * and technical concepts contained herein are proprietary to Adobe
// * and its suppliers and are protected by all applicable intellectual
// * property laws, including trade secret and copyright laws.
// * Dissemination of this information or reproduction of this material
// * is strictly forbidden unless prior written permission is obtained
// * from Adobe.
// **************************************************************************/
package com.adobe.mediaanalyticstestapp;

import android.os.Bundle;
import android.app.Activity;
import android.net.Uri;
import android.view.View;

import com.adobe.mediaanalyticstestapp.analytics.VideoAnalyticsProvider;
import com.adobe.mediaanalyticstestapp.player.PlayerEvent;
import com.adobe.mediaanalyticstestapp.player.VideoPlayer;

import java.util.Observable;
import java.util.Observer;


public class MediaActivity extends Activity implements Observer {
    private VideoPlayer _player;
    private VideoAnalyticsProvider _analyticsProvider;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activitymedia);

        // Create the VideoPlayer instance.
        _player = new VideoPlayer(this);

        _player.addObserver(this);

        // Create the VideoAnalyticsProvider instance and
        // attach it to the VideoPlayer instance.
        _analyticsProvider = new VideoAnalyticsProvider(_player);

        // Load the main video content.
        Uri uri = Uri.parse("android.resource://" + getPackageName() + "/" + R.raw.video);
        _player.loadContent(uri);
    }

    @Override
    protected void onDestroy() {
        _analyticsProvider.destroy();
        _analyticsProvider = null;
        _player = null;

        super.onDestroy();
    }

    @Override
    public void update(Observable observable, Object o) {
        PlayerEvent playerEvent = (PlayerEvent) o;

        switch (playerEvent) {
            case AD_START:
                _onEnterAd();
                break;

            case AD_COMPLETE:
                _onExitAd();
                break;

            case SEEK_COMPLETE:
                if (_player.getAdInfo() == null) {
                    // The user seeked outside the ad.
                    _onExitAd();
                }

                break;
        }
    }

    private void _onEnterAd() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                findViewById(R.id.adOverlayView).setVisibility(View.VISIBLE);
            }
        });
    }

    private void _onExitAd() {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                findViewById(R.id.adOverlayView).setVisibility(View.INVISIBLE);
            }
        });
    }
}
