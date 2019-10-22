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

#import <ACPMedia.h>
#import <ACPMediaConstants.h>

@interface MediaTrackerHelper : NSObject

- (instancetype _Nonnull) initWithConfig: (NSDictionary* _Nullable) config;

- (void) trackSessionStart: (NSDictionary* _Nonnull) mediaObject data: (NSDictionary* _Nullable) data;

- (void) trackPlay;

- (void) trackPause;

- (void) trackComplete;

- (void) trackSessionEnd;

- (void) trackError: (NSString* _Nonnull) errorId;

- (void) trackEvent: (ACPMediaEvent) event mediaObject: (NSDictionary* _Nullable) mediaObject data:
(NSDictionary* _Nullable) data;

- (void) updateCurrentPlayhead: (double) time;

- (void) updateQoEObject: (NSDictionary* _Nonnull) qoeObject;


@end
