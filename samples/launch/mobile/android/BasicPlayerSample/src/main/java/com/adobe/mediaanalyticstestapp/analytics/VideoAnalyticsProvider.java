/*************************************************************************
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 * Copyright 2018 Adobe
 * All Rights Reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Adobe and its suppliers, if any. The intellectual
 * and technical concepts contained herein are proprietary to Adobe
 * and its suppliers and are protected by all applicable intellectual
 * property laws, including trade secret and copyright laws.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe.
 **************************************************************************/

package com.adobe.mediaanalyticstestapp.analytics;

import android.util.Log;
import com.adobe.marketing.mobile.Media;
import com.adobe.marketing.mobile.MediaConstants;
import com.adobe.marketing.mobile.MediaTracker;
import com.adobe.mediaanalyticstestapp.Configuration;
import com.adobe.mediaanalyticstestapp.player.*;

import java.util.*;

public class VideoAnalyticsProvider implements Observer {
	private static final String LOG_TAG = "[Sample]::" + VideoAnalyticsProvider.class.getSimpleName();

	private VideoPlayer _player;
	private MediaTracker _tracker;

	public VideoAnalyticsProvider(VideoPlayer player) {
		if (player == null) {
			throw new IllegalArgumentException("Player reference cannot be null.");
		}

		_player = player;
		HashMap<String, Object> config = new HashMap<>();
		config.put(MediaConstants.Config.CHANNEL, "android_v5_sample");
		// Enable this for tracking downloaded content.
		// config.put(MediaConstants.Config.DOWNLOADED_CONTENT, true);		
		_tracker = Media.createTracker(config);

		_player.addObserver(this);
	}

	public void destroy() {
		if (_player != null) {
			_tracker.trackSessionEnd();
			_tracker = null;

			_player.destroy();
			_player.deleteObserver(this);
			_player = null;
		}
	}

	@Override
	public void update(Observable observable, Object data) {
		PlayerEvent playerEvent = (PlayerEvent) data;

		switch (playerEvent) {
			case VIDEO_LOAD:
				Log.d(LOG_TAG, "Video loaded.");
				HashMap<String, String> videoMetadata = new HashMap<String, String>();
				videoMetadata.put("isUserLoggedIn", "false");
				videoMetadata.put("tvStation", "Sample TV Station");
				videoMetadata.put("programmer", "Sample programmer");
				// Set Standard Video Metadata as context data
				videoMetadata.put(MediaConstants.VideoMetadataKeys.EPISODE, "Sample Episode");
				videoMetadata.put(MediaConstants.VideoMetadataKeys.SHOW, "Sample Show");

				HashMap<String, Object> mediaInfo = Media.createMediaObject(
														Configuration.VIDEO_NAME,
														Configuration.VIDEO_ID,
														Configuration.VIDEO_LENGTH,
														MediaConstants.StreamType.VOD,
														Media.MediaType.Video
													);

				//Set to true if this is a resume playback scenario (not starting from playhead 0)
				// mediaInfo.put(MediaConstants.MediaObjectKey.RESUMED, true);

				_tracker.trackSessionStart(mediaInfo, videoMetadata);
				break;

			case VIDEO_UNLOAD:
				Log.d(LOG_TAG, "Video unloaded.");
				_tracker.trackSessionEnd();
				break;

			case PLAY:
				Log.d(LOG_TAG, "Playback started.");
				_tracker.trackPlay();
				break;

			case PAUSE:
				Log.d(LOG_TAG, "Playback paused.");
				_tracker.trackPause();
				break;

			case SEEK_START:
				Log.d(LOG_TAG, "Seek started.");
				_tracker.trackEvent(Media.Event.SeekStart, null, null);
				break;

			case SEEK_COMPLETE:
				Log.d(LOG_TAG, "Seek completed.");
				_tracker.trackEvent(Media.Event.SeekComplete, null, null);
				break;

			case BUFFER_START:
				Log.d(LOG_TAG, "Buffer started.");
				_tracker.trackEvent(Media.Event.BufferStart, null, null);
				break;

			case BUFFER_COMPLETE:
				Log.d(LOG_TAG, "Buffer completed.");
				_tracker.trackEvent(Media.Event.BufferComplete, null, null);
				break;

			case AD_START:
				Log.d(LOG_TAG, "Ad started.");
				HashMap<String, String> adMetadata = new HashMap<String, String>();
				adMetadata.put("affiliate", "Sample affiliate");
				adMetadata.put("campaign", "Sample ad campaign");
				// Setting standard Ad Metadata
				adMetadata.put(MediaConstants.AdMetadataKeys.ADVERTISER, "Sample Advertiser");
				adMetadata.put(MediaConstants.AdMetadataKeys.CAMPAIGN_ID, "Sample Campaign");

				// Ad Break Info
				Map<String, Object> adBreakData = _player.getAdBreakInfo();
				String name = (String) adBreakData.get("name");
				Long position = (Long) adBreakData.get("position");
				Double startTime = (Double) adBreakData.get("startTime");

				HashMap<String, Object> adBreakInfo = Media.createAdBreakObject(name, position, startTime);

				// Ad Info
				Map<String, Object> adData = _player.getAdInfo();
				String adName = (String) adData.get("name");
				String adId = (String) adData.get("id");
				Long adPosition = (Long) adData.get("position");
				Double adLength = (Double) adData.get("length");

				HashMap<String, Object> adInfo = Media.createAdObject(adName, adId, adPosition, adLength);
				_tracker.trackEvent(Media.Event.AdBreakStart, adBreakInfo, null);
				_tracker.trackEvent(Media.Event.AdStart, adInfo, adMetadata);
				break;

			case AD_COMPLETE:
				Log.d(LOG_TAG, "Ad completed.");
				_tracker.trackEvent(Media.Event.AdComplete, null, null);
				_tracker.trackEvent(Media.Event.AdBreakComplete, null, null);
				break;

			case CHAPTER_START:
				Log.d(LOG_TAG, "Chapter started.");
				HashMap<String, String> chapterMetadata = new HashMap<String, String>();
				chapterMetadata.put("segmentType", "Sample Segment Type");

				// Chapter Info
				Map<String, Object> chapterData = _player.getChapterInfo();
				String chapterName = (String) chapterData.get("name");
				Long chapterPosition = (Long) chapterData.get("position");
				Double chapterLength = (Double) chapterData.get("length");
				Double chapterStartTime = (Double) chapterData.get("startTime");

				HashMap<String, Object> chapterDataInfo = Media.createChapterObject(chapterName, chapterPosition, chapterLength,
						chapterStartTime);

				_tracker.trackEvent(Media.Event.ChapterStart, chapterDataInfo, chapterMetadata);
				break;

			case CHAPTER_COMPLETE:
				Log.d(LOG_TAG, "Chapter completed.");
				_tracker.trackEvent(Media.Event.ChapterComplete, null, null);
				break;

			case COMPLETE:
				Log.d(LOG_TAG, "Playback completed.");

				_tracker.trackComplete();
				break;

			case PLAYHEAD_UPDATE:
				// Log.d(LOG_TAG, "Playhead update.");
				_tracker.updateCurrentPlayhead(_player.getCurrentPlaybackTime());
				break;

			case PLAYER_STATE_MUTE_START:
				Log.d(LOG_TAG, "Player State(Mute).");
				HashMap<String, Object>stateInfo = Media.createStateObject(MediaConstants.PlayerState.MUTE);
				_tracker.trackEvent(Media.Event.StateStart, stateInfo, null);
				break;

			case PLAYER_STATE_MUTE_END:
				Log.d(LOG_TAG, "Player State End.");
				stateInfo = Media.createStateObject(MediaConstants.PlayerState.MUTE);
				_tracker.trackEvent(Media.Event.StateEnd, stateInfo, null);
				break;

			default:
				Log.d(LOG_TAG, "Unhandled player event: " + playerEvent.toString());
				break;
		}
	}
}
