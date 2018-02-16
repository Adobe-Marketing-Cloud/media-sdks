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

#import "ADBMediaHeartbeatConfig.h"
#import "ADBStandardMetadataKeys.h"

/**
 * These enumeration values define the type of a tracking event
 */
typedef NS_ENUM(NSInteger, ADBMediaHeartbeatEvent)
{
    /**
     * Constant defining event type for AdBreak start
     */
	ADBMediaHeartbeatEventAdBreakStart,
    /**
     * Constant defining event type for AdBreak complete
     */
	ADBMediaHeartbeatEventAdBreakComplete,
    /**
     * Constant defining event type for Ad start
     */
	ADBMediaHeartbeatEventAdStart,
    /**
     * Constant defining event type for Ad complete
     */
	ADBMediaHeartbeatEventAdComplete,
    /**
     * Constant defining event type for Ad skip
     */
	ADBMediaHeartbeatEventAdSkip,
    /**
     * Constant defining event type for Chapter start
     */
	ADBMediaHeartbeatEventChapterStart,
    /**
     * Constant defining event type for Chapter complete
     */
	ADBMediaHeartbeatEventChapterComplete,
    /**
     * Constant defining event type for Chapter skip
     */
	ADBMediaHeartbeatEventChapterSkip,
    /**
     * Constant defining event type for Seek start
     */
	ADBMediaHeartbeatEventSeekStart,
    /**
     * Constant defining event type for Seek complete
     */
	ADBMediaHeartbeatEventSeekComplete,
    /**
     * Constant defining event type for Buffer start
     */
	ADBMediaHeartbeatEventBufferStart,
    /**
     * Constant defining event type for Buffer complete
     */
	ADBMediaHeartbeatEventBufferComplete,
    /**
     * Constant defining event type for change in Bitrate
     */
	ADBMediaHeartbeatEventBitrateChange,
    /**
     * Constant defining event type for TimedMetadata update received from the player
     */
	ADBMediaHeartbeatEventTimedMetadataUpdate
};


#pragma mark - ADBMediaHeartbeatSteamType constants
/**
 * These constant strings define the stream type of the main content that is currently tracked.
 */

/**
 * Constant defining stream type for VOD streams
 */
FOUNDATION_EXPORT NSString * __nonnull const ADBMediaHeartbeatStreamTypeVOD;

/**
 * Constant defining stream type for Live streams
 */
FOUNDATION_EXPORT NSString * __nonnull const ADBMediaHeartbeatStreamTypeLIVE;

/**
 * Constant defining stream type for Linear streams
 */
FOUNDATION_EXPORT NSString * __nonnull const ADBMediaHeartbeatStreamTypeLINEAR;


#pragma mark - ADBMediaObjectKey constants
/**
 * These constant strings define media info keys
 */

/**
 * Constant defining Map of Standard Video Metadata to be attached on MediaObject
 */
FOUNDATION_EXPORT NSString * __nonnull const ADBMediaObjectKeyStandardVideoMetadata;
/**
 * Constant defining Map of Standard Ad Metadata to be attached on MediaObject
 */
FOUNDATION_EXPORT NSString * __nonnull const ADBMediaObjectKeyVideoResumed;
/**
 * Constant defining the time that MediaHeartbeat waits to start tracking pre-roll ad before tracking the video start
 */
FOUNDATION_EXPORT NSString * __nonnull const ADBMediaObjectKeyPrerollTrackingWaitingTime;

/**
 * These constant strings define ad info keys
 */
FOUNDATION_EXPORT NSString * __nonnull const ADBMediaObjectKeyStandardAdMetadata;


#pragma mark - ADBMediaObject Interface

@interface ADBMediaObject : NSObject

/**
 * Sets the specified value for the key.
 *
 * @param value A non-null value for the key. Any existing value for the key is replaced by the new value. 
 * @param key The name of the key to be set.
 */
- (void)setValue:(nullable id)value forKey:(nonnull NSString *)key;

/**
 * Returns the value of the specified key.
 *
 * The key must be a non empty value.
 *
 * @param key The name of the key whose value  is to be returned.
 * @return The value for the specified key or nil if there is no corresponding value for the key
 */
- (nullable id)valueForKey:(nonnull NSString *)key;

/**
 * Returns all the keys as an NSArray instance
 *
 * @return A new array containing the keys, or an empty array if this instance has no entries.
 */
- (nonnull NSArray *)allKeys;

@end


#pragma mark - ADBMediaHeartbeatDelegate Protocol

@protocol ADBMediaHeartbeatDelegate <NSObject>

@required

/**
 * Returns the ADBMediaObject instance containing current QoS information. This method can be called
 * multiple times during a playback session. Player implementation must always return the most
 * recently available QoS data.
 */
- (nonnull ADBMediaObject *)getQoSObject;

/**
 * Current position of the playhead. For VOD, value is specified in seconds from the beginning of the media item.
 * For live streaming, return playhead position if available or the current UTC time in seconds otherwise.
 */
- (NSTimeInterval)getCurrentPlaybackTime;

@end


#pragma mark - ADBMediaHeartbeat Interface

@interface ADBMediaHeartbeat : NSObject

/**
 * 	@brief Gets the version.
 *  @return a string pointer containing the version value.
 */
+ (nonnull NSString *)version;


#pragma mark - Initialization

+ (nonnull instancetype)new NS_UNAVAILABLE;
- (nonnull instancetype)init NS_UNAVAILABLE;

/**
 * Creates an instance of ADBMediaHeartbeat class with provided delegate
 *
 * @param delegate
 * @param config
 */
- (nonnull instancetype)initWithDelegate:(nonnull id<ADBMediaHeartbeatDelegate>)delegate config:(nonnull ADBMediaHeartbeatConfig *)config;


#pragma mark - Media Lifecycle Track

/**
 * Tracking method to track the start of a viewing session.
 *
 * @param mediaObject An ADBMediaObject instance created using createMediaObjectWithName method
 * @param data a dictionary pointer containing the context data to be tracked.
 */
- (void)trackSessionStart:(nonnull ADBMediaObject *)mediaObject data:(nullable NSDictionary *)data;

/**
 * Video playback tracking method to track Video Play and a resume after a previous pause.
 */
- (void)trackPlay;

/**
 * Video playback tracking method to track Video Pause
 */
- (void)trackPause;

/**
 * Video playback tracking method to track Video Complete
 *
 */
- (void)trackComplete;

/**
 * Tracking method to track the end of a viewing session. This method must be called even if the user
 * does not watch the video to completion.
 */
- (void)trackSessionEnd;

/**
 * Tracking method to track an error in media playback
 *
 * param errorId A string describing the error
 */
- (void)trackError:(nonnull NSString *)errorId;


#pragma mark - Media Events Track

/**
 * Video playback tracking method to track an event
 *
 * @param event
 * @param info
 * @param data a dictionary pointer containing the context data to be tracked.
 */
- (void)trackEvent:(ADBMediaHeartbeatEvent)event mediaObject:(nullable ADBMediaObject *)mediaObject data:(nullable NSDictionary *)data;


#pragma mark - Create Methods

/**
 * Creates an instance of the video info object
 *
 * @param name The name of the media
 * @param mediaId The unqiue identifier for the media
 * @param length The length of the media in seconds
 * @param streamType The stream type as a string. Use the pre-defined constants for vod, live, and linear content
 */
+ (nonnull ADBMediaObject *)createMediaObjectWithName:(nonnull NSString *)name
					  mediaId:(nonnull NSString *)mediaId
					   length:(double)length
				   streamType:(nonnull NSString *)streamType;

/**
 * Creates an instance of the AdBreak info object
 *
 * @param name The name of the ad break
 * @param position The position of the ad break in the content starting with 1
 * @param startTime The start time of the ad break relative to the main media
 */
+ (nonnull ADBMediaObject *)createAdBreakObjectWithName:(nonnull NSString *)name
					   position:(double)position
					  startTime:(double)startTime;

/**
 * Creates an instance of the Ad info object
 *
 * @param name The name of the ad
 * @param adId The unique id for the ad
 * @param position The start position of the ad
 * @param length The length of the ad in seconds
 */
+ (nonnull ADBMediaObject *)createAdObjectWithName:(nonnull NSString *)name
									  adId:(nonnull NSString *)adId
								position:(double)position
								  length:(double)length;

/**
 * Creates an instance of the Chapter info object
 *
 * @param name The name of the chapter
 * @param position The position of the chapter
 * @param length The length of the chapter in seconds
 * @param startTime The start of the chapter relative to the main media
 */
+ (nonnull ADBMediaObject *)createChapterObjectWithName:(nonnull NSString *)name
									  position:(double)position
										length:(double)length
									 startTime:(double)startTime;

/**
 * Creates an instance of the QoS info object
 *
 * @param bitrate The bitrate of media in bits per second
 * @param startupTime The start up time of media in seconds
 * @param fps The current frames per second information
 * @param droppedFrames The number of dropped frames so far
 */
+ (nonnull ADBMediaObject *)createQoSObjectWithBitrate:(double)bitrate
								  startupTime:(double)startupTime
										  fps:(double)fps
								droppedFrames:(double)droppedFrames;

/**
 * Creates an instance of the Timed Metadata media object
 *
 * @param metadata The timed metadata string value
 */
+ (nonnull ADBMediaObject *)createTimedMetadataObject:(nonnull NSString *)metadata;


@end
