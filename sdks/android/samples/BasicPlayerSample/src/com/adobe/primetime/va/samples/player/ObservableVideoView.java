/*************************************************************************
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2015 Adobe
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

package com.adobe.primetime.va.samples.player;

import android.content.Context;
import android.util.AttributeSet;
import android.util.Log;
import android.widget.VideoView;

public class ObservableVideoView extends VideoView {
    private static final String LOG_TAG = "[MediaSDKSample]::" + ObservableVideoView.class.getSimpleName();

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
