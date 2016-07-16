package com.adobe.primetime.va.samples;

import android.app.Activity;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;

import com.adobe.mobile.AudienceManager;
import com.adobe.mobile.Config;
import com.adobe.primetime.va.samples.analytics.VideoAnalyticsProvider;
import com.adobe.primetime.va.samples.player.PlayerEvent;
import com.adobe.primetime.va.samples.player.VideoPlayer;

import java.util.Observable;
import java.util.Observer;


public class MainActivity extends Activity implements Observer {
    private VideoPlayer _player;
    private VideoAnalyticsProvider _analyticsProvider;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        // Bootstrap the AppMeasurement library.
        Config.setContext(this.getApplicationContext());

        // sample for setting AudienceManager dpid and dpuuid
        AudienceManager.setDpidAndDpuuid("67312378756723456", "550e8400-e29b-41d4-a716-446655440000");

        // Create the VideoPlayer instance.
        _player = new VideoPlayer(this);

        _player.addObserver(this);

        // Create the VideoAnalyticsProvider instance and
        // attach it to the VideoPlayer instance.
        _analyticsProvider = new VideoAnalyticsProvider(_player);

        // Load the main video content.
        Uri uri = Uri.parse("android.resource://" + getPackageName() + "/" + R.raw.clickbaby);
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
