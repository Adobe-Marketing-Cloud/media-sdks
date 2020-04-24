# Migrating from 2.x JS SDK to 3.x JS SDK

## New Features

- Use MediaCollection APIs
- Custom state tracking

## Improvements

- Provide global configuration for media library
- Simple tracker creation
- Added APIs to providing playhead and QoE information.
- API to destroy tracker instance.
- Simplify setting standard/custom metadata for media and ads.

## API Comparison

### Media Class

| Functionality | 2.x | 3.x |
| ------ | ------ | ------ |
| **Namespace** | ADB.va.MediaHeartbeat | **ADB.Media** |
| **Configuration** | Parameter of MediaHeartbeat constructor | **configure(mediaConfig, appMeasurement)** |
| **Create Tracker** | new MediaHeartbeat(...) | **getInstance()** |
| **Static methods** | ||
||createMediaObject(...)| createMediaObject(...)|
||createAdBreakObject(...)| createAdBreakObject(...)|
||createAdObject(...)| createAdObject(...)|
||createChapterObject(...)| createChapterObject(...)|
||createQoSObject(...)| **createQoEObject**(...)|
||N/A| **createStateObject()**|
| **Instance methods** | ||
|| trackSessionStart(...) | trackSessionStart(...) |
|| trackPlay() | trackPlay() |
|| trackPause() | trackPause() |
|| trackComplete() | trackComplete() |
|| trackSessionEnd() | trackSessionEnd() |
|| trackEvent(...) | trackEvent(...) |
|| trackError(...) | trackError(...) |
|| N/A | **updatePlayhead(playhead)** |
|| N/A | **updateQoEObject(qoeObject)** |
|**Destroy Tracker**| N/A | **destroy()** |

### MediaConfig Class

| Functionality | 2.x | 3.x |
| ------ | ------ | ------ |
| **Namespace** | ADB.va.MediaHeartbeatConfig | **ADB.MediaConfig** |
| **Constructor** | new MediaHeartbeatConfig() | **new MediaConfig()** |
| **Configuration Parameters** | | |
| | trackingServer | trackingServer |
| | channel | channel |
| | ovp | N/A |
| | appVersion | appVersion |
| | playerName | playerName |
| | ssl | ssl |
| | debugLogging | debugLogging |

## Code comparison

### Configuration and tracker creation

#### 2.x
```javascript
    var MediaHeartbeat = ADB.va.MediaHeartbeat;
    var MediaHeartbeatConfig = ADB.va.MediaHeartbeatConfig;
    var MediaHeartbeatDelegate = ADB.va.MediaHeartbeatDelegate;

    // Create MediaHeartbeatConfig object
    var mediaConfig = new MediaHeartbeatConfig();
    mediaConfig.trackingServer = "tracking_server";
    mediaConfig.playerName = "player_name";
    mediaConfig.channel = "sample_channel";
    mediaConfig.ovp = "sample_ovp";
    mediaConfig.appVersion = "app_version";
    mediaConfig.debugLogging = true;
    mediaConfig.ssl = true;

    // Instance of MediaHeartbeatDelegate to return playhead and qosInfo to the tracker
    ADB.core.extend(SampleMediaHeartbeatDelegate.prototype,
                         MediaHeartbeatDelegate.prototype);
    function SampleMediaHeartbeatDelegate() { ... }
    SampleMediaHeartbeatDelegate.prototype.getCurrentPlaybackTime = function() {
        // Returns the current playhead from the player.
    }
    SampleMediaHeartbeatDelegate.prototype.getQoSObject = function() {
        // Returns the current QOS information if available from the player.
    }

    // Create tracker instance by passing mediaConfig, appMeasurement instancee and player delegate
    var tracker = new MediaHeartbeat( new SampleMediaHeartbeatDelegate(),
                                      mediaConfig,
                                      appMeasurement);
```

#### 3.x
```javascript

    var Media = ADB.Media;
    var MediaConfig = ADB.MediaConfig;

    // Create MediaConfig object (same as above)
    var mediaConfig = new MediaConfig();
    mediaConfig.trackingServer = "tracking_server";
    mediaConfig.playerName = "player_name";
    mediaConfig.channel = "sample_channel";
    mediaConfig.appVersion = "app_version";
    mediaConfig.debugLogging = true;
    mediaConfig.ssl = true;

    // Configuration is only done once per page
    // and applies to all tracker instances created.
    Media.configure(mediaConfig, appMeasurement);

    // Tracker creation.
    var tracker = Media.getInstance();
```

### Provide Playhead and QoE information to tracker

#### 2.x
```javascript

    // Instance of MediaHeartbeatDelegate to return playhead and qosInfo to the tracker
    ADB.core.extend(SampleMediaHeartbeatDelegate.prototype,
                         MediaHeartbeatDelegate.prototype);
    function SampleMediaHeartbeatDelegate(player) { this.player = player }
    SampleMediaHeartbeatDelegate.prototype.getCurrentPlaybackTime = function() {
        // Returns the current playhead from the player.
        return this.player.playhead;
    };
    SampleMediaHeartbeatDelegate.prototype.getQoSObject = function() {
        // Returns the current QOS information if available from the player.
        var qosInfo = MediaHeartbeat.createQoSObject(this._player.bitrate,
                                                     this._player.startupTime,
                                                     this._player.fps,
                                                     this._player.droppedFrames);
        return qosInfo;
    };

    // Pass the delegate instance when creating the tracker.
    var tracker = new MediaHeartbeat( new SampleMediaHeartbeatDelegate(),
                                      mediaConfig,
                                      appMeasurement);

```

#### 3.x
```javascript

        // When playhead changes, call
        tracker.updatePlayhead(this._player.playhead)

        // When new QoE information is available, call
        var qoeInfo = Media.createQoEObject(this._player.bitrate,
                                                     this._player.startupTime,
                                                     this._player.fps,
                                                     this._player.droppedFrames);
        tracker.updateQoEObject(qoeInfo)
```

### Standard and custom metadata for Media and Ads

#### Media

#### 2.x
```javascript
    var mediaObject = MediaHeartbeat.createMediaObject("name",
                                                       "id",
                                                       60.0,
                                                       MediaHeartbeat.StreamType.VOD,
                                                       MediaHeartbeat.MediaType.Video);
    // standard metadata
    var standardMetadata = {};
    standardMetadata[MediaHeartbeat.VideoMetadataKeys.SEASON] = "sample season";
    standardMetadata[MediaHeartbeat.VideoMetadataKeys.SHOW] = "sample show";
    // Set standard metadata on media object.
    mediaObject.setValue(MediaHeartbeat.MediaObjectKey.StandardMediaMetadata,
                               standardMetadata);

    // custom metadata
    var customMetadata = {
        "customKey1" : "custom value",
        "customKey2" : "custom value"
    };

    mediaTracker.trackSessionStart(mediaObject, customMetadata);
```

#### 3.x
```javascript
    var mediaObject = Media.createMediaObject("name",
                                           "id",
                                           60.0,
                                           Media.StreamType.VOD,
                                           Media.MediaType.Video);

    var metadata = {};
    // standard metadata
    metadata[Media.VideoMetadataKeys.Season] = "sample season";
    metadata[Media.VideoMetadataKeys.Show] = "sample show";
    // custom metadata
    metadata["customKey1"] = "custom value";
    metadata["customKey2"] = "custom value";

    mediaTracker.trackSessionStart(mediaObject, metadata);
```

#### Ads

#### 2.x
```javascript
    var adObject = MediaHeartbeat.createAdObject("adName",
                                                 "adId",
                                                  1,
                                                  15.0);

    // standard metadata
    var standardAdMetadata = {};
    standardAdMetadata[MediaHeartbeat.AdMetadataKeys.ADVERTISER] = "Sample Advertiser";
    standardAdMetadata[MediaHeartbeat.AdMetadataKeys.CAMPAIGN_ID] = "Sample Campaign";
    // Set standard metadata on ad object.
    adObject.setValue(MediaHeartbeat.MediaObjectKey.StandardAdMetadata,
                               standardAdMetadata);

    // custom metadata
    var customMetadata = {
        "customKey1" : "custom value",
        "customKey2" : "custom value"
    };

    mediaTracker.trackEvent(MediaHeartbeat.Event.AdStart, adObject, customMetadata);
```

#### 3.x
```javascript

    var adObject = Media.createAdObject("adName",
                                                 "adId",
                                                  1,
                                                  15.0);


    var metadata = {};
    // standard metadata
    metadata[Media.AdMetadataKeys.Advertiser] = "Sample Advertiser";
    metadata[Media.AdMetadataKeys.CampaignId] = "Sample Campaign";
    // custom metadata
    metadata["customKey1"] = "custom value";
    metadata["customKey2"] = "custom value";

    mediaTracker.trackEvent(Media.Event.AdStart, adObject, metadata);
```