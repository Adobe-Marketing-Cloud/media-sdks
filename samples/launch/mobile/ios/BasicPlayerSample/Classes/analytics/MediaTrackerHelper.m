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

#import "MediaTrackerHelper.h"

// MediaTracker creation is asynchronous with V5 SDK. In this class, we queue all the track requests 
// and issue them once the tracker instance is created.
// You can use this optional helper class to easily migrate from existing VHL implementation.

typedef NS_ENUM(NSInteger, CallType) {
    TrackSessionStart,
    TrackSessionEnd,
    TrackComplete,
    TrackPlay,
    TrackPause,
    TrackEvent,
    TrackError,
    UpdatePlayhead,
    UpdateQoE
};

@interface CallData: NSObject
    @property CallType  callType;
    @property NSObject* arg0;
    @property ACPMediaEvent eventArg0;
    @property NSObject* arg1;
    @property NSObject* arg2;
@end

@implementation CallData
- (instancetype _Nonnull) initWithType: (CallType) calltype {
    if(self = [super init]) {
        self.callType = calltype;
    }
    return self;
}
@end

@implementation MediaTrackerHelper
{
    ACPMediaTracker* _tracker;
    NSMutableArray *_pendingCalls;
    NSObject* _lock;
    BOOL _isInitialized;
    BOOL _inError;
}

- (instancetype _Nonnull) initWithConfig: (NSDictionary* _Nullable) config {
    if(self = [super init]) {
        _isInitialized = NO;
        _inError = NO;
        _lock = [[NSObject alloc] init];
        _pendingCalls = [[NSMutableArray alloc] init];
        
        __weak MediaTrackerHelper* wSelf = self;
        [ACPMedia createTrackerWithConfig:config callback:^(ACPMediaTracker* tracker){
            MediaTrackerHelper* sSelf = wSelf;
            if(!sSelf){
                return;
            }
            [wSelf onTrackerCreated:tracker];
        }];
    }
    return self;
}

- (void) onTrackerCreated:(ACPMediaTracker*) tracker {
    @synchronized (_lock) {
        if (!tracker) {
            _inError = true;
            return;
        }
        
        _tracker = tracker;
        
        for (CallData* callData in _pendingCalls) {
            [self process:callData];
        }
        
        _isInitialized = true;
    }
}

- (void) trackSessionStart: (NSDictionary* _Nonnull) mediaObject data: (NSDictionary* _Nullable) data {
    CallData* callData = [[CallData alloc] initWithType:TrackSessionStart];
    callData.arg0 = mediaObject;
    callData.arg1 = data;
    [self track:callData];
}

- (void) trackPlay {
    CallData* callData = [[CallData alloc] initWithType:TrackPlay];
    [self track:callData];
}

- (void) trackPause {
    CallData* callData = [[CallData alloc] initWithType:TrackPause];
    [self track:callData];
}

- (void) trackComplete {
    CallData* callData = [[CallData alloc] initWithType:TrackComplete];
    [self track:callData];
}

- (void) trackSessionEnd {
    CallData* callData = [[CallData alloc] initWithType:TrackSessionEnd];
    [self track:callData];
}

- (void) trackError: (NSString* _Nonnull) errorId {
    CallData* callData = [[CallData alloc] initWithType:TrackError];
    callData.arg0 = errorId;
    [self track:callData];
}

- (void) trackEvent: (ACPMediaEvent) event mediaObject: (NSDictionary* _Nullable) mediaObject data:
(NSDictionary* _Nullable) data {
    CallData* callData = [[CallData alloc] initWithType:TrackEvent];
    callData.eventArg0 = event;
    callData.arg1 = mediaObject;
    callData.arg2 = data;
    [self track:callData];
}

- (void) updateCurrentPlayhead: (double) time {
    CallData* callData = [[CallData alloc] initWithType:UpdatePlayhead];
    callData.arg0 = [NSNumber numberWithDouble:time];
    [self track:callData];
}

- (void) updateQoEObject: (NSDictionary* _Nonnull) qoeObject {
    CallData* callData = [[CallData alloc] initWithType:UpdateQoE];
    callData.arg0 = qoeObject;
    [self track:callData];
}


- (void) track: (CallData*) callData {
    @synchronized (_lock) {
        if (_inError) {
            return;
        }
        
        if (!_isInitialized) {
            [_pendingCalls addObject:callData];
            return;
        }
        
        [self process:callData];
    }
}

- (void) process: (CallData*) callData {
    switch (callData.callType) {
        case TrackSessionStart:
            [_tracker trackSessionStart: (NSDictionary*)callData.arg0 data: (NSDictionary*) callData.arg1];
        
            break;
            
        case TrackPlay:
            [_tracker trackPlay];
            break;
            
        case TrackPause:
            [_tracker trackPause];
            break;
            
        case TrackComplete:
            [_tracker trackComplete];
            break;
            
        case TrackSessionEnd:
            [_tracker trackSessionEnd];
            break;
            
        case TrackError:
            [_tracker trackError:(NSString *) callData.arg0];
            break;
            
        case TrackEvent:
            [_tracker trackEvent:callData.eventArg0 info:(NSDictionary*)callData.arg1 data:(NSDictionary*) callData.arg2];
            break;
            
        case UpdatePlayhead:
            [_tracker updateCurrentPlayhead:[(NSNumber*)callData.arg0 doubleValue]];
            break;
            
        case UpdateQoE:
            [_tracker updateQoEObject:(NSDictionary*)callData.arg0];
            break;
    }
}
@end
