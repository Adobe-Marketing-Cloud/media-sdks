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

#import <Foundation/Foundation.h>

/**
 * MediaHeartbeat configuration
 */
@interface ADBMediaHeartbeatConfig : NSObject

/** @name Properties */
/**
 * Define the server for tracking media heartbeats. This is different from your analytics tracking server.
 */
@property (nonatomic, strong) NSString *trackingServer;

/** @name Properties */
/**
 * Channel name property. Defaults value is empty string.
 */
@property (nonatomic, strong) NSString *channel;

/** @name Properties */
/**
 * Name of the online video platform through which content gets distributed. Default value is empty string.
 */
@property (nonatomic, strong) NSString *ovp;

/** @name Properties */
/**
 * Version of the media player app/SDK. Default value is empty string.
 */
@property (nonatomic, strong) NSString *appVersion;

/** @name Properties */
/**
 * Name of the media player on use. i.e. "AVPlayer", "HTML5 Player", "My Custom VideoPlayer". Default value is empty string.
 */
@property (nonatomic, strong) NSString *playerName;

/** @name Properties */
/**
 * Property that indicates whether the heartbeat calls should be made over HTTPS. Default value is NO.
 */
@property (nonatomic) BOOL ssl;

/** @name Properties */
/**
 * Property that indicates the preference for debug log output. Default value is NO.
 */
@property (nonatomic) BOOL debugLogging;

@end
