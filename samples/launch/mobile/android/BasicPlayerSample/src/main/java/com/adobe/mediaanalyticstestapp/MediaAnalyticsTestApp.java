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

package com.adobe.mediaanalyticstestapp;

import android.app.Application;

import com.adobe.marketing.mobile.*;

public class MediaAnalyticsTestApp extends Application {

	@Override
	public void onCreate() {
		super.onCreate();
		MobileCore.setApplication(this);
		MobileCore.setLogLevel(LoggingMode.DEBUG);

		try {
			Analytics.registerExtension();
			Media.registerExtension();
			Identity.registerExtension();
			MobileCore.start(new AdobeCallback () {
				@Override
				public void call(Object o) {
					MobileCore.configureWithAppID("94f571f308d5/44ff240a3399/launch-e04a1f758d3d-development");
				}
			});
		} catch (InvalidInitException ex) {

		}
	}
}
