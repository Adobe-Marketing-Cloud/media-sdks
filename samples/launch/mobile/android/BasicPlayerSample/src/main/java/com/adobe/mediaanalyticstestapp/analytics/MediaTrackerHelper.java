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

// MediaTracker creation is asynchronous with V5 SDK. In this class, we queue all the track requests 
// and issue them once the tracker instance is created.
// You can use this optional helper class to easily migrate from existing VHL implementation.

import android.util.Log;

import com.adobe.marketing.mobile.AdobeCallback;
import com.adobe.marketing.mobile.Media;
import com.adobe.marketing.mobile.MediaTracker;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

public class MediaTrackerHelper {
	private static String LOG_TAG = MediaTrackerHelper.class.getName();

	private enum CallName {
		TrackSessionStart,
		TrackSessionEnd,
		TrackComplete,
		TrackPlay,
		TrackPause,
		TrackEvent,
		TrackError,
		UpdateQoE,
		UpdatePlayhead
	}

	private class CallData {
		CallName method;
		Object arg0, arg1, arg2;
		CallData(CallName method) {
			this(method, null, null, null);
		}
		CallData(CallName method, Object arg0) {
			this(method, arg0, null, null);
		}
		CallData(CallName method, Object arg0, Object arg1) {
			this(method, arg0, arg1, null);
		}
		CallData(CallName method, Object arg0, Object arg1, Object arg2) {
			this.method = method;
			this.arg0 = arg0;
			this.arg1 = arg1;
			this.arg2 = arg2;
		}
	}

	private ArrayList<CallData> pendingCalls;
	private MediaTracker tracker;
	private boolean inError;
	private boolean isInitialized;
	private Object lock = new Object();

	MediaTrackerHelper() {
		this(null);
	}

	MediaTrackerHelper(HashMap<String, Object> config) {

		pendingCalls = new ArrayList<CallData>();
		inError = false;
		isInitialized = false;


		AdobeCallback<MediaTracker> createdClb = new AdobeCallback<MediaTracker>() {
			@Override
			public void call(MediaTracker tracker) {

				synchronized (lock) {
					if (tracker == null) {
						inError = true;
						return;
					}

					MediaTrackerHelper.this.tracker = tracker;

					for (CallData callData : pendingCalls) {
						process(callData);
					}

					isInitialized = true;
				}
			}
		};

		Media.createTracker(config, createdClb);
	}

	public void trackSessionStart(HashMap<String, Object> mediaInfo, Map<String, String> contextData) {
		track(new CallData(CallName.TrackSessionStart, mediaInfo, contextData));
	}

	public void trackPlay() {
		track(new CallData(CallName.TrackPlay));
	}

	public void trackPause() {
		track(new CallData(CallName.TrackPause));
	}

	public void trackComplete() {
		track(new CallData(CallName.TrackComplete));
	}

	public void trackSessionEnd() {
		track(new CallData(CallName.TrackSessionEnd));
	}

	public void trackError(String errorId) {
		track(new CallData(CallName.TrackError, errorId));
	}

	public void trackEvent(Media.Event event, HashMap<String, Object> info, Map<String, String> contextData) {
		track(new CallData(CallName.TrackEvent, event, info, contextData));
	}

	public void updateQoEObject(HashMap<String, Object> qosObject) {
		track(new CallData(CallName.UpdateQoE, qosObject));
	}

	public void updateCurrentPlayhead(double time) {
		track(new CallData(CallName.UpdatePlayhead, (Double)time));
	}



	private void track(CallData callData) {
		synchronized (lock) {
			if (inError) {
				Log.d(LOG_TAG, "Error creating tracker. Dropping call " + callData.method);
				return;
			}

			if (!isInitialized) {
				pendingCalls.add(callData);
				return;
			}

			process(callData);
		}
	}

	private void process(CallData callData) {
		switch (callData.method) {
			case TrackSessionStart:
				tracker.trackSessionStart((HashMap<String, Object>)callData.arg0, (Map<String, String>)callData.arg1);
				break;

			case TrackPlay:
				tracker.trackPlay();
				break;

			case TrackPause:
				tracker.trackPause();
				break;

			case TrackComplete:
				tracker.trackComplete();
				break;

			case TrackSessionEnd:
				tracker.trackSessionEnd();
				break;

			case TrackError:
				tracker.trackError((String)callData.arg0);
				break;

			case TrackEvent:
				tracker.trackEvent((Media.Event) callData.arg0, (HashMap<String, Object>)callData.arg1,
								   (Map<String, String>)callData.arg2);
				break;

			case UpdateQoE:
				tracker.updateQoEObject((HashMap<String, Object>)callData.arg0);
				break;

			case UpdatePlayhead:
				tracker.updateCurrentPlayhead((Double) callData.arg0);
				break;
		}
	}
}
