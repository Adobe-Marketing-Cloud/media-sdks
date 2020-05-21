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

package com.adobe.mediaanalyticstestapp.player;

public enum PlayerEvent {
	VIDEO_LOAD("video_load"),
	VIDEO_UNLOAD("video_unload"),
	PLAY("play"),
	PAUSE("pause"),
	SEEK_START("seek_start"),
	SEEK_COMPLETE("seek_complete"),
	BUFFER_START("buffer_start"),
	BUFFER_COMPLETE("buffer_complete"),
	AD_START("ad_start"),
	AD_COMPLETE("ad_complete"),
	CHAPTER_START("chapter_start"),
	CHAPTER_COMPLETE("chapter_complete"),
	COMPLETE("complete"),
	PLAYHEAD_UPDATE("playhead_update"),
	PLAYER_STATE_MUTE_START("player_state_mute_start"),
	PLAYER_STATE_MUTE_END("player_state_mute_end");

	private final String _type;

	PlayerEvent(String type) {
		_type = type;
	}

	public String getType() {
		return _type;
	}
}
