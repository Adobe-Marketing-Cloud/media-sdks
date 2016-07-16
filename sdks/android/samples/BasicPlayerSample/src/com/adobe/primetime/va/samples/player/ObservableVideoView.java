/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2014 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */

package com.adobe.primetime.va.samples.player;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.VideoView;

public class ObservableVideoView extends VideoView {
    private static final String LOG_TAG = "[VideoHeartbeatSample]::" + ObservableVideoView.class.getSimpleName();

    private VideoPlayer _player;

    public ObservableVideoView(Context context) {
        super(context);
    }

    public ObservableVideoView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public ObservableVideoView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    public void setVideoPlayer(VideoPlayer player) {
        _player = player;
    }

    @Override
    public void start() {
        super.start();

        Log.d(LOG_TAG, "Resuming playback.");

        if (_player != null) {
            _player.resumePlayback();
        }
    }

    @Override
    public void pause() {
        super.pause();

        Log.d(LOG_TAG, "Pausing playback.");

        if (_player != null) {
            _player.pausePlayback();
        }
    }

    @Override
    public void seekTo(int msec) {
        super.seekTo(msec);

        Log.d(LOG_TAG, "Starting seek.");

        if (_player != null) {
            _player.seekStart();
        }
    }
}
