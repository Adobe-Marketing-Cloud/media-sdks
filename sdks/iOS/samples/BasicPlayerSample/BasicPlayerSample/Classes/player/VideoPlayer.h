/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2015 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const PLAYER_EVENT_VIDEO_LOAD;
FOUNDATION_EXPORT NSString *const PLAYER_EVENT_VIDEO_UNLOAD;
FOUNDATION_EXPORT NSString *const PLAYER_EVENT_PLAY;
FOUNDATION_EXPORT NSString *const PLAYER_EVENT_PAUSE;
FOUNDATION_EXPORT NSString *const PLAYER_EVENT_COMPLETE;
FOUNDATION_EXPORT NSString *const PLAYER_EVENT_SEEK_START;
FOUNDATION_EXPORT NSString *const PLAYER_EVENT_SEEK_COMPLETE;
FOUNDATION_EXPORT NSString *const PLAYER_EVENT_AD_START;
FOUNDATION_EXPORT NSString *const PLAYER_EVENT_AD_COMPLETE;
FOUNDATION_EXPORT NSString *const PLAYER_EVENT_CHAPTER_START;
FOUNDATION_EXPORT NSString *const PLAYER_EVENT_CHAPTER_COMPLETE;


@protocol VideoPlayerDelegate <NSObject>

@required

- (NSTimeInterval)getCurrentPlaybackTime;

@end


@interface VideoPlayer : NSObject <VideoPlayerDelegate>

- (void)loadContentUrl:(NSURL *)url;
- (UIView *)getView;

@end
