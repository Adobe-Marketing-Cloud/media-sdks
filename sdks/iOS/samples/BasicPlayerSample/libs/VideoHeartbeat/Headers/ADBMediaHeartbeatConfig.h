/*************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 *  Copyright 2016 Adobe Systems Incorporated
 *  All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 *
 **************************************************************************/

#import <Foundation/Foundation.h>

@interface ADBMediaHeartbeatConfig : NSObject

/** @name Properties */
/**
 * Define the server for tracking media heartbeats. This is different from your analytics tracking server.
 */
@property (nonatomic, strong) NSString *trackingServer;

/** @name Properties */
/**
 * channel name property, defaults to empty string.
 */
@property (nonatomic, strong) NSString *channel;

/** @name Properties */
/**
 * Name of the online video platform through which content gets distributed. Default value is "unknown".
 */
@property (nonatomic, strong) NSString *ovp;

/** @name Properties */
/**
 * Version of the video player app/SDK. Default value is "unknown".
 */
@property (nonatomic, strong) NSString *appVersion;

/** @name Properties */
/**
 * Name of the video player on use. i.e. "AVPlayer", "HTML5 Player", "My Custom VideoPlayer".
 */
@property (nonatomic, strong) NSString *playerName;

/** @name Properties */
/**
 * Property that indicates whether the heartbeat calls should be made over HTTPS. Default value is NO.
 */
@property (nonatomic) BOOL ssl;

/** @name Properties */
/**
 * 	@brief Gets the preference for debug log output.
 *  @return a bool value indicating the preference for debug log output.
 */
@property (nonatomic) BOOL debugLogging;

@end