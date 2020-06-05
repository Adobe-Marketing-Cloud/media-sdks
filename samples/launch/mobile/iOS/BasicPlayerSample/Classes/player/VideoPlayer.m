/* ************************************************************************
 *
 * ADOBE CONFIDENTIAL
 * ___________________
 *
 * Copyright 2018 Adobe Systems Incorporated
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Adobe Systems Incorporated and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Adobe Systems Incorporated and its
 * suppliers and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Adobe Systems Incorporated.
 **************************************************************************/

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

#import "VideoPlayer.h"

NSString *const PLAYER_EVENT_VIDEO_LOAD = @"player_video_load";
NSString *const PLAYER_EVENT_VIDEO_UNLOAD = @"player_video_unload";
NSString *const PLAYER_EVENT_PLAY = @"player_play";
NSString *const PLAYER_EVENT_PAUSE = @"player_pause";
NSString *const PLAYER_EVENT_COMPLETE = @"player_complete";
NSString *const PLAYER_EVENT_SEEK_START = @"player_seek_start";
NSString *const PLAYER_EVENT_SEEK_COMPLETE = @"player_seek_complete";
NSString *const PLAYER_EVENT_AD_START = @"player_ad_start";
NSString *const PLAYER_EVENT_AD_COMPLETE = @"player_ad_complete";
NSString *const PLAYER_EVENT_CHAPTER_START = @"player_chapter_start";
NSString *const PLAYER_EVENT_CHAPTER_COMPLETE = @"player_chapter_complete";
NSString *const PLAYER_EVENT_PLAYHEAD_UPDATE = @"player_playhead_update";
NSString *const PLAYER_EVENT_CC_CHANGE = @"player_cc_change";
NSString *const PLAYER_EVENT_MUTE_CHANGE = @"player_mute_change";


NSUInteger const AD_START_POS = 15;
NSUInteger const AD_END_POS = 30;
NSUInteger const AD_LENGTH = 15;

NSUInteger const CHAPTER1_START_POS = 0;
NSUInteger const CHAPTER1_END_POS = 15;
NSUInteger const CHAPTER1_LENGTH = 15;

NSUInteger const CHAPTER2_START_POS = 30;
NSUInteger const CHAPTER2_LENGTH = 30;

NSTimeInterval const MONITOR_TIMER_INTERVAL = 0.5; // 500 milliseconds

#pragma mark - Static Context
static void *VHLMediaPlayerKVOContext = &VHLMediaPlayerKVOContext;

NSString *kStatusKey				= @"status";
NSString *kRateKey					= @"rate";
NSString *kDurationKey				= @"duration";
NSString *kMuteKey                  = @"muted";
NSString *kPlaybackBufferEmpty      = @"playbackBufferEmpty";
NSString *kPlaybackBufferFull       = @"playbackBufferFull";
NSString *kPlaybackLikelyToKeepUp   = @"playbackLikelyToKeepUp";

@interface VideoPlayer ()

@property(nonatomic) BOOL videoLoaded;
@property(nonatomic) BOOL isMuted;
@property(nonatomic) BOOL isCCActive;
@property(nonatomic, getter=isSeeking) BOOL seeking;
@property(nonatomic, getter=isPaused) BOOL paused;

@property(strong, nonatomic) AVPlayerViewController *avPlayerViewcontroller;
@property(weak, nonatomic) NSTimer *monitorTimer;

@end


@implementation VideoPlayer
{
	BOOL _isInChapter;
	BOOL _isInAd;
	int _chapterPosition;
}

#pragma mark Initializer & dealloc

- (void)loadContentUrl:(NSURL *)url
{
	AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
	
	playerViewController.player = [AVPlayer playerWithURL:url];
    //playerViewController.player.muted = true;
	self.avPlayerViewcontroller = playerViewController;
	
	[self.avPlayerViewcontroller.player addObserver:self forKeyPath:kStatusKey options:0 context:VHLMediaPlayerKVOContext];
	[self.avPlayerViewcontroller.player addObserver:self forKeyPath:kRateKey  options:0 context:VHLMediaPlayerKVOContext];
    [self.avPlayerViewcontroller.player addObserver:self forKeyPath:kMuteKey  options:0 context:VHLMediaPlayerKVOContext];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(onMediaFinishedPlaying:)
												 name:AVPlayerItemDidPlayToEndTimeNotification
											   object:nil];
	
	_videoLoaded = NO;
	_seeking = NO;
    _isMuted = NO;
    _isCCActive = NO;
	_paused = YES;
}

- (UIView *)getView
{
	return self.avPlayerViewcontroller.view;
}

- (NSTimeInterval)getCurrentPlaybackTime
{
	return CMTimeGetSeconds(self.avPlayerViewcontroller.player.currentTime);
}

- (double)duration
{
	return CMTimeGetSeconds(self.avPlayerViewcontroller.player.currentItem.duration);
}

- (void)dealloc
{
	[_monitorTimer invalidate];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark Native VideoPlayer control notification handlers

- (void)onMediaFinishedPlaying:(NSNotification *)notification
{
	[self completeVideo];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context != &VHLMediaPlayerKVOContext)
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		return;
	}
	
	if ([keyPath isEqualToString:kStatusKey])
	{
		if (self.avPlayerViewcontroller.player.status == AVPlayerStatusFailed)
		{
			[self pausePlayback];
		}
	}
    else if ([keyPath isEqualToString:kMuteKey])
    {
        if (_isMuted != self.avPlayerViewcontroller.player.muted) {
            _isMuted = self.avPlayerViewcontroller.player.muted;
            [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_MUTE_CHANGE
                                                                object:self
                                                              userInfo:@{
                                                                        @"muted" : [NSNumber numberWithBool:_isMuted]
                                                                         }];
        }
    }
	else if ([keyPath isEqualToString:kRateKey])
	{
		if (self.avPlayerViewcontroller.player.rate == 0.0f)
		{
			[self pausePlayback];
		}
		else
		{
			if (self.isSeeking)
			{
				NSLog(@"Stop seeking.");
				self.seeking = NO;
				[self doPostSeekComputations];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_SEEK_COMPLETE
																	object:self
																  userInfo:nil];
			}
			else
			{
				NSLog(@"Resume playback.");
				[self openVideoIfNecessary];
				self.paused = NO;
				[[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_PLAY
																	object:self
																  userInfo:nil];
			}
		}
	}
}


#pragma mark Private helper methods

- (void)openVideoIfNecessary
{
	if (!self.videoLoaded)
	{
		[self resetInternalState];
		[self startVideo];
		
		// Start the monitor timer.
		self.monitorTimer = [NSTimer scheduledTimerWithTimeInterval:MONITOR_TIMER_INTERVAL
															 target:self
														   selector:@selector(onTimerTick)
														   userInfo:nil
															repeats:YES];
	}
}

- (void)pauseIfSeekHasNotStarted
{
	if (!self.isSeeking)
	{
		[self pausePlayback];
	}
	else
	{
		NSLog(@"This pause is caused by a seek operation. Skipping.");
	}
}

- (void)pausePlayback
{
	NSLog(@"Pausing playback.");
	
	self.paused = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_PAUSE
														object:self
													  userInfo:nil];
}

- (void)startVideo
{
	// Prepare the video info.
	self.videoLoaded = YES;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_VIDEO_LOAD
														object:self
													  userInfo:nil];
}

- (void)completeVideo
{
	// Complete the second chapter.
	[self completeChapter];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_COMPLETE
														object:self
													  userInfo:nil];
	
	[self unloadVideo];
}

- (void)unloadVideo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_VIDEO_UNLOAD
														object:self
													  userInfo:nil];
	
	[self.monitorTimer invalidate];
	
	[self resetInternalState];
}

- (void)resetInternalState
{
	self.videoLoaded = NO;
	self.seeking = NO;
	self.paused = YES;
	self.monitorTimer = nil;
}

- (void)startChapter1
{
	_isInChapter = YES;
	_chapterPosition = 1;
	
	NSDictionary *chapterInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"First Chapter", @"name",
								 @(CHAPTER1_LENGTH), @"length",
								 @1, @"position",
								 @(CHAPTER1_START_POS), @"time",
								 nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_CHAPTER_START
														object:self
													  userInfo:chapterInfo];
}

- (void)startChapter2
{
	_isInChapter = YES;
	_chapterPosition = 2;
	
	NSDictionary *chapterInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"Second Chapter", @"name",
								 @(CHAPTER2_LENGTH), @"length",
								 @2, @"position",
								 @(CHAPTER2_START_POS), @"time",
								 nil];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_CHAPTER_START
														object:self
													  userInfo:chapterInfo];
}

- (void)completeChapter
{
	_isInChapter = NO;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_CHAPTER_COMPLETE object:self userInfo:nil];
}

- (void)startAd
{
	_isInAd = YES;
	
	NSDictionary *adBreakInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"First Ad-Break", @"name",
								 @(AD_START_POS), @"time",
								 @1, @"position",
								 nil];
	
	NSDictionary *adInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							@"Sample Ad", @"name",
							@"001", @"id",
							@1, @"position",
							@(AD_LENGTH), @"length",
							nil];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  adBreakInfo, @"adbreak",
							  adInfo, @"ad",
							  nil];
	
	// Start the ad.
	[[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_AD_START object:self userInfo:userInfo];
}

- (void)completeAd
{
	// Complete the ad.
	[[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_AD_COMPLETE object:self userInfo:nil];
	
	// Clear the ad and ad-break info.
	_isInAd = NO;
}

- (void)doPostSeekComputations
{
	NSTimeInterval vTime = [self getCurrentPlaybackTime];
	
	// Seek inside the first chapter.
	if (vTime < CHAPTER1_END_POS)
	{
		// If we were not inside the first chapter before, trigger a chapter start
		if (!_isInChapter || _chapterPosition != 1)
		{
			[self startChapter1];
			
			// If we were in the ad, clear the ad and ad-break info, but don't send the AD_COMPLETE event.
			if (_isInAd)
			{
				_isInAd = NO;
			}
		}
	}
	
	// Seek inside ad.
	else if (vTime >= AD_START_POS && vTime < AD_END_POS)
	{
		// If we were not inside the ad before, trigger an ad-start.
		if (!_isInAd)
		{
			[self startAd];
			
			// Also, clear the chapter info, without sending the CHAPTER_COMPLETE event.
			_isInChapter = NO;
		}
	}
	else // Seek inside the second chapter.
	{
		// If we were not inside the 2nd chapter before, trigger a chapter start
		if (!_isInChapter || _chapterPosition != 2)
		{
			[self startChapter2];
			
			// If we were in the ad, clear the ad and ad-break info, but don't send the AD_COMPLETE event.
			if (_isInAd)
			{
				_isInAd = NO;
			}
		}
	}
}

- (void)onTimerTick
{
	if (self.isSeeking || self.isPaused) return;
	
	NSTimeInterval vTime = [self getCurrentPlaybackTime];
	
	// If we are inside the ad content:
	if (vTime >= AD_START_POS && vTime < AD_END_POS)
	{
		if (_isInChapter)
		{
			// If for some reason we were inside a chapter, close it.
			[self completeChapter];
		}
		
		if (!_isInAd)
		{
			// Start the ad (if not already started).
			[self startAd];
		}
	}
	
	// Otherwise, we are outside the ad content:
	else
	{
		if (_isInAd)
		{
			// Complete the ad (if needed).
			[self completeAd];
		}
		
		if (vTime < CHAPTER1_END_POS)
		{
			if (_isInChapter && _chapterPosition != 1)
			{
				// If we were inside another chapter, complete it.
				[self completeChapter];
			}
			
			if (!_isInChapter)
			{
				// Start the first chapter.
				[self startChapter1];
			}
		}
		else
		{
			if (_isInChapter && _chapterPosition != 2)
			{
				// If we were inside another chapter, complete it.
				[self completeChapter];
			}
			
			if (!_isInChapter)
			{
				// Start the second chapter.
				[self startChapter2];
			}
		}
	}
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@(vTime), @"time",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_PLAYHEAD_UPDATE object:self userInfo:userInfo];
    
    [self detectCCChange];
}

- (void) detectCCChange {
AVPlayerItem* currentItem = self.avPlayerViewcontroller.player.currentItem;
AVAsset* asset = currentItem.asset;

AVMediaSelectionGroup* group = [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicLegible];
AVMediaSelectionOption* option = [currentItem.currentMediaSelection selectedMediaOptionInMediaSelectionGroup:group];
bool ccStatus = (option != NULL);
if (_isCCActive != ccStatus) {
    _isCCActive = ccStatus;
    [[NSNotificationCenter defaultCenter] postNotificationName:PLAYER_EVENT_CC_CHANGE
                                                        object:self
                                                      userInfo:@{
                                                                 @"ccActive" : [NSNumber numberWithBool:_isCCActive]
                                                                 }];
    }
}

@end
