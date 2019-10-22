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

#import <MediaPlayer/MediaPlayer.h>

#import "ViewController.h"
#import "VideoPlayer.h"
#import "VideoAnalyticsProvider.h"

NSString *const CONTENT_URL = @"http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8";

@interface ViewController ()

@property(strong, nonatomic) UILabel *pubLabel;
@property(strong, nonatomic) VideoPlayer *videoPlayer;
@property(strong, nonatomic) VideoAnalyticsProvider *videoAnalyticsProvider;

@end


@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Setup the video player
    if (!self.videoPlayer)
    {
        self.videoPlayer = [[VideoPlayer alloc] init];
		[self.videoPlayer loadContentUrl:[NSURL URLWithString:CONTENT_URL]];

        [[self.videoPlayer getView] setFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        [self.view addSubview:[self.videoPlayer getView]];
		
		
		self.pubLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 200.0, 200.0)];
		self.pubLabel.text = @"AD";
		self.pubLabel.hidden = YES;
		[self.pubLabel setTextColor:[UIColor whiteColor]];
		[self.pubLabel setFont:[UIFont fontWithDescriptor:[UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline]
												   size:64.0f]];
		
		[self.view addSubview:self.pubLabel];
		
        [self.view bringSubviewToFront:self.pubLabel];
        
        [self addNotificationHandlers];
    }
    
    // Create the VideoAnalyticsProvider instance and attach it to the VideoPlayer instance.
    if (!self.videoAnalyticsProvider)
    {
        self.videoAnalyticsProvider = [[VideoAnalyticsProvider alloc] initWithPlayerDelegate:self.videoPlayer];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    // End the life-cycle of the VideoAnalytics provider. (or full screen)
    [super viewWillDisappear:animated];
	
	// remove all observers
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotificationHandlers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAdStart:)
                                                 name:PLAYER_EVENT_AD_START
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onAdComplete:)
                                                 name:PLAYER_EVENT_AD_COMPLETE
                                               object:nil];
}

- (void)onAdStart:(NSNotification *)notification
{
    _pubLabel.hidden = NO;
}

- (void)onAdComplete:(NSNotification *)notification
{
    _pubLabel.hidden = YES;
}

@end
