# MediaSDK API reference

## ADB.Media

### Static methods

#### configure

> **_Note:_** 
This method is for standalone Media SDK JavaScript v3.x.  
For Media SDK Javascript v3.x with Tags extension, setup the configuration via Data Collection UI (Tags UI).

Configures MediaSDK for tracking. This method should be called once before creating any tracker instances in a page.

**Syntax**

```javascript
ADB.Media.configure(mediaConfig, appMeasurement);
```

|Variable Name | Type | Description |
|---|---|---
| mediaConfig | [ADB.MediaConfig](#ADB.MediaConfig) | Valid media configuration |
| appMeasurement | object | AppMeasurement instance |

**Example**

```javascript
var mediaConfig = new ADB.MediaConfig();
mediaConfig.trackingServer = "company.hb-api.omtrdc.net";
mediaConfig.playerName = "player_name";
mediaConfig.channel = "sample_channel";
mediaConfig.appVersion = "app_version";
mediaConfig.debugLogging = true;
mediaConfig.ssl = true;

ADB.Media.configure(mediaConfig, appMeasurement);
```

#### getInstance

Creates an instance of media to track the playback session. Returns `null` is called before [configuring media](#configure).

**Syntax**

```javascript
ADB.Media.getInstance()
```

**Example**

```javascript
var tracker = ADB.Media.getInstance();
```

 ```javascript
 // create an instance with custom channel example
 // this overrides the channel which was set during the configuration
 var tracker = ADB.Media.getInstance({"media.channel":"custom_channel_name"})
 ```

#### createMediaObject

Creates an object containing media information. Returns empty object if invalid parameters are passed.

**Syntax**

```javascript
ADB.Media.createMediaObject(name, id, length, streamType, mediaType)
```

| Variable Name | Type | Description |
| :--- | :--- | :---: |
| `name` | string | Non empty string denoting media name |
| `id` | string | Non empty string denoting unique media identifier |
| `length` |  number | Positive number denoting length of media in seconds. Use `0` if length is unknown. |
| `streamType` | string | [Stream type](#stream-type) or non empty string to denote media stream type. |
| `mediaType` | [Media type](#media-type) | Type of media (Audio or Video) |

**Example**

```javascript
var mediaObject = ADB.Media.createMediaObject("video-name",
                                              "video-id",
                                              60.0,
                                              ADB.Media.StreamType.VOD,
                                              ADB.Media.MediaType.Video);
```

#### createAdBreakObject

Creates an object containing adbreak information. Returns empty object if invalid parameters are passed.

**Syntax**

```javascript
ADB.Media.createAdBreakObject(name, position, startTime);
```

| Variable Name | Type | Description |
| :--- | :--- | :---: |
| `name` | string | Non empty string denoting adbreak name (pre-roll, mid-roll, and post-roll) |
| `position` | number | The number position of the ad break within the content, starting with 1 |
| `startTime` |  number | Playhead value at the start of the ad break. |

**Example**

```javascript
var adbreakObject = ADB.Media.createAdBreakObject("midroll", 2, 30.0);
```

#### createAdObject

Creates an object containing ad information. Returns empty object if invalid parameters are passed.

**Syntax**

```javascript
ADB.Media.createAdObject(name, id, position, length);
```

| Variable Name | Type | Description |
| :--- | :--- | :---: |
| `name` | string | Non empty string denoting ad name |
| `id` | string | Non empty string denoting ad id |
| `position` | number | The number position of the ad within the adbreak, starting with 1 |
| `length` |  number | Positive number denoting length of the ad |

**Example**

```javascript
var adObject = ADB.Media.createAdObject("ad-name", "ad-id", 1, 15.0)
```

#### createChapterObject

Creates an object containing chapter information. Returns empty object if invalid parameters are passed.

**Syntax**

```javascript
ADB.Media.createChapterObject(name, position, length, startTime)
```

| Variable Name | Type | Description |
| :--- | :--- | :---: |
| `name` | string | Non empty string denoting chapter name |
| `position` | number | The position of the chapter within the content, starting with 1 |
| `length` |  number | Positive number denoting length of the chapter |
| `startTime` |  number | Playhead value at start of chapter |

**Example**

```javascript
var chapterObject = ADB.Media.createChapterObject("name", 1, 30.0, 0)

```

#### createStateObject

Creates an object containing state information. Returns empty object if invalid parameters are passed.

**Syntax**

```javascript
ADB.Media.createStateObject(name)
```

| Variable Name | Type | Description |
| :--- | :--- | :---: |
| `name` | string | [Player State](#player-states) or non empty string denoting state name |

**Example**

```javascript
var stateObject = ADB.Media.createStateObject("customstate");
```

#### createQoEObject

Creates an object containing QoE information. Returns empty object if invalid parameters are passed.

**Syntax**

```javascript
ADB.Media.createQoEObject(bitrate, startupTime, fps, droppedFrames)
```

| Variable Name | Type | Description |
| :--- | :--- | :---: |
| `bitrate` | number | Positive number denoting current bitrate (0 if unknown)|
| `startupTime` | number | Positive number denoting startup time (0 if unknown) |
| `fps` |  number | Positive number denoting current fps (0 if unknown) |
| `droppedFrames` | number |  Positive number denoting number of dropped frames (0 if unknown) |

**Example**

```javascript
qoeObject = ADB.Media.createQoEObject(10000000, 2, 23, 10);
```

#### version

Returns MediaSDK version

**Syntax**

```javascript
ADB.Media.version
```

**Example**

```javascript
console.log(ADB.Media.version);
```

### Instance methods

#### trackSessionStart

Track the intention to start playback. This starts a tracking session on the media tracker instance. Also see [Media Resume](#media-resume).

**Syntax**

```javascript
ADB.Media.trackSessionStart(mediaObject, contextData);
```

| Variable Name | Description | Required |
| :--- | :--- | :---: |
| `mediaObject` | Media information created using the [createMediaObject](#createMediaObject) method. | Yes |
| `contextData` | Optional Media context data. For standard metadata keys, use [standard video constants](#standard-video-constants) or [standard audio constants](#standard-audio-constants). | No |

**Example**

```javascript
var mediaObject = ADB.Media.createMediaObject("media-name", "media-id", 60, ADB.Media.StreamType.VOD, ADB.Media.MediaType.Video);

var contextData = {};
contextData[ADB.Media.VideoMetadataKeys.Episode] = "Sample Episode";
contextData[ADB.Media.VideoMetadataKeys.Show] = "Sample Show";
contextData["isUserLoggedIn"] = "false";
contextData["tvStation"] = "Sample TV Station";

tracker.trackSessionStart(mediaObject, contextData);
```

#### trackPlay

Track media play or resume after a previous pause.

**Syntax**

```javascript
ADB.Media.trackPlay();
```

**Example**

```javascript
tracker.trackPlay();
```

#### trackPause

Track media pause.

**Syntax**

```javascript
ADB.Media.trackPause();
```

**Example**

```javascript
tracker.trackPause();
```

#### trackComplete

Track media complete. Call this method only when the media has been completely viewed.

**Syntax**

```javascript
ADB.Media.trackComplete();
```

**Example**

```javascript
tracker.trackComplete();
```

#### trackSessionEnd

Track the end of a viewing session. Call this method even if the user does not view the media to completion.

**Syntax**

```javascript
ADB.Media.trackSessionEnd();
```

**Example**

```javascript
tracker.trackSessionEnd();
```

#### trackError

Track an error in media playback.

**Syntax**

```javascript
ADB.Media.trackError(errorId);
```

| Variable Name | Description | Required |
| :--- | :--- | :---: |
| `errorId` | Non empty string containing error information | Yes |

**Example**

```javascript
tracker.trackError("errorId");
```

#### trackEvent

Method to track media events.

| Variable Name | Description |
| :--- | :--- |
| `event` | [Media event](#media-events) |
| `info` | For `AdBreakStart` event, the adbreak information is created by using the [createAdBreakObject](#createAdBreakObject) method.  For `AdStart` event, the ad information is created by using the [createAdObject](#createAdObject) method.  For `ChapterStart` event, the chapter information is created by using the [createChapterObject](#createChapterObject) method.  For `StateStart` and `StateEnd` events, the state information is created by using the [createStateObject](#createStateObject) method. This is not required for other events. |
| `contextData` | Optional context data can be provided for `AdStart` and `ChapterStart` events. This is not required for other events. |

**Syntax**

```javascript
ADB.Media.trackEvent(event, info, contextData);
```

**Examples**

**Tracking AdBreaks**

```javascript
// AdBreakStart
  var adBreakObject = ADB.Media.createAdBreakObject("preroll", 1, 0)
  tracker.trackEvent(ADB.Media.Event.AdBreakStart, adBreakObject);

// AdBreakComplete
  tracker.trackEvent(ADB.Media.Event.AdBreakComplete);
```

**Tracking ads**

```javascript
// AdStart
  var adObject = ADB.Media.createAdObject("ad-name", "ad-id", 1, 15.0);

  var adMetadata = {};
  // Standard metadata keys provided by adobe.
  adMetadata[ADB.Media.AdMetadataKeys.Advertiser]  ="Sample Advertiser";
  adMetadata[ADB.Media.AdMetadataKeys.CampaignId] = "Sample Campaign";
  // Custom metadata keys  
  adMetadata["affiliate"] = "Sample affiliate";
  
  tracker.trackEvent(ADB.Media.Event.AdStart, adObject, adMetadata);

// AdComplete
  tracker.trackEvent(ADB.Media.Event.AdComplete);

// AdSkip
  tracker.trackEvent(ADB.Media.Event.AdSkip);
```

**Tracking chapters**

```javascript
// ChapterStart
  var chapterObject = ADB.Media.createChapterObject("chapter-name", 1, 60.0, 15.0);

  var chapterMetadata = {};
  chapterMetadata["segmentType"] = "Sample segment type";

  tracker.trackEvent(ADB.Media.Event.ChapterStart, chapterObject, chapterMetadata);

// ChapterComplete
  tracker.trackEvent(ADB.Media.Event.ChapterComplete);

// ChapterSkip
  tracker.trackEvent(ADB.Media.Event.ChapterSkip);
```

**Tracking states**

```javascript
// StateStart (ex: Mute is switched on)
  var stateObject = ADB.Media.createStateObject(ADB.Media.PlayerState.Mute);
  tracker.trackEvent(ADB.Media.Event.StateStart, stateObject);

// StateEnd (ex: Mute is switched off)
  tracker.trackEvent(ADB.Media.Event.StateEnd, stateObject);
```

**Tracking playback events**

```javascript
// BufferStart
  tracker.trackEvent(ADB.Media.Event.BufferStart);

// BufferComplete
  tracker.trackEvent(ADB.Media.Event.BufferComplete);

// SeekStart
  tracker.trackEvent(ADB.Media.Event.SeekStart);

// SeekComplete
  tracker.trackEvent(ADB.Media.Event.SeekComplete);
```

**Tracking bitrate changes**

```javascript
// If the new bitrate value is available provide it to the tracker.
  var qoeObject = ADB.Media.createQoEObject(1000000, 2.4, 25, 10);
  tracker.updateQoEObject(qoeObject);

// Bitrate change
  tracker.trackEvent(ADB.Media.Event.BitrateChange);
```

#### updatePlayhead

Provides the current media playhead to the media tracker instance. For accurate tracking, call this method everytime the playhead changes. If the player does not notify playhead changes, call this method once every second with the most recent playhead.

**Syntax**

```javascript
ADB.Media.updatePlayhead(time);
```

| Variable Name | Description |
| :--- | :--- |
| `time` | Current playhead in seconds. <br /> For video-on-demand \(VOD\), the value is specified in seconds from the beginning of the media item. <br /> For live streaming, if the player does not provide information about the content duration, the value can be specified as the number of seconds since midnight UTC of that day. <br /> Note: When using progress markers,the content duration is required and the playhead needs to be updated as number of seconds from the beginning of the media item, starting with 0.|

**Example**

```javascript
tracker.updatePlayhead(13.3);

//live streaming case example:
var UTCTimeInSeconds = Math.floor(Date.now() / 1000)
var timeFromMidnightInSecond = UTCTimeInSeconds % 86400
tracker.updatePlayhead(timeFromMidnightInSecond);
```

#### updateQoEObject

Provides current QoE information to the media tracker. For accurate tracking, call this method multiple times when the media player provides the updated QoE information.

**Syntax**

```javascript
ADB.Media.updateQoEObject(qoeObject);
```


| Variable Name | Description |
| :--- | :--- |
| `qoeObject` | Current QoE information that was created by using the [createQoEObject](#createQoEObject) method. |

**Example**

```javascript
var qoeObject = ADB.Media.createQoEObject(1000000, 2.4, 25, 10);
tracker.updateQoEObject(qoeObject);
```

#### destroy

Destroys the tracker instance.

**Syntax**

```javascript
ADB.Media.destroy();
```

**Example**

```javascript
tracker.destroy();
```

### Constants

#### Media type

This defines the type of a media that is currently tracked.

```javascript
ADB.Media.MediaType = {
  Video: "video",
  Audio: "audio"
}
```

#### Stream type

This defines the stream type of the content that is currently tracked.

```javascript
ADB.Media.StreamType = {
  VOD: "vod",
  Live: "live",
  Linear: "linear",
  Podcast: "podcast",
  Audiobook: "audiobook",
  AOD: "aod"
}
```

#### Standard video constants

This defines the standard metadata keys for video streams.

```javascript
ADB.Media.VideoMetadataKeys {
  Show: "a.media.show",
  Season: "a.media.season",
  Episode: "a.media.episode",
  AssetId: "a.media.asset",
  Genre: "a.media.genre",
  FirstAirDate: "a.media.airDate",
  FirstDigitalDate: "a.media.digitalDate",
  Rating: "a.media.rating",
  Originator: "a.media.originator",
  Network: "a.media.network",
  ShowType: "a.media.type",
  AdLoad: "a.media.adLoad",
  MVPD: "a.media.pass.mvpd",
  Authorized: "a.media.pass.auth",
  DayPart: "a.media.dayPart",
  Feed: "a.media.feed",
  StreamFormat: "a.media.format"
}
```

#### Standard audio constants

This defines the standard metadata keys for audio streams.

```javascript
ADB.Media.AudioMetadataKeys {
  Artist: "a.media.artist",
  Album: "a.media.album",
  Label: "a.media.label",
  Author: "a.media.author",
  Station: "a.media.station",
  Publisher: "a.media.publisher"
}
```

#### Standard ad constants

This defines the standard metadata keys for ads.

```javascript
ADB.Media.AdMetadataKeys {
  Advertiser: "a.media.ad.advertiser",
  CampaignId: "a.media.ad.campaign",
  CreativeId: "a.media.ad.creative",
  PlacementId: "a.media.ad.placement",
  SiteId: "a.media.ad.site",
  CreativeUrl: "a.media.ad.creativeURL"
}
```

#### Media events

This defines the type of a tracking event.

```javascript
ADB.Media.Event = {
  AdBreakStart: "adBreakStart",
  AdBreakComplete: "adBreakComplete",
  AdStart: "adStart",
  AdComplete: "adComplete",
  AdSkip: "adSkip",
  ChapterStart: "chapterStart",
  ChapterComplete: "chapterComplete",
  ChapterSkip: "chapterSkip",
  SeekStart: "seekStart",
  SeekComplete: "seekComplete",
  BufferStart: "bufferStart",
  BufferComplete: "bufferComplete",
  BitrateChange: "bitrateChange",
  StateStart: "stateStart",
  StateEnd: "stateEnd"
}
```

#### Player states

This defines standard values for tracking player state.

```javascript
ADB.Media.PlayerState = {
  FullScreen: "fullScreen",
  ClosedCaption: "closedCaptioning",
  Mute: "mute",
  PictureInPicture: "pictureInPicture",
  InFocus: "inFocus"
}
```

#### Media resume

Constant to denote that the current tracking session is resuming a previously closed session. This information must be provided when starting a tracking session.

**Syntax**

```javascript
 ADB.Media.MediaObjectKey = {
    MediaResumed: "resumed"
}
```

**Example**

```javascript
var mediaObject = ADB.Media.createMediaObject("media-name", "media-id", 60, ADB.Media.StreamType.VOD, ADB.Media.MediaType.Video);

mediaObject[ADB.Media.MediaObjectKey.MediaResumed] = true;

tracker.trackSessionStart(mediaObject);
```

## ADB.MediaConfig

| Key | Required | Description |
| :--- | :--- | :--- |
| `trackingServer` | Yes | Type the name of the media collection API server to which the downloaded media tracking data should be sent. Contact your Adobe account representative to receive this information. |
| `channel` | No | Channel name property |
| `playerName` | No | Name of the media player in use  |
| `appVersion` | No | Type the version of the media player application/SDK |
| `debugLogging` | No | Enables or disables Media SDK logs (Default value : `false`)|
| `ssl` | No | Sends pings over SSL (Default value : `true`)|