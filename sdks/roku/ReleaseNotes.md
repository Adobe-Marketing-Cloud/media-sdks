# Release Notes for BrightScript (Roku) Adobe Mobile Library version 2.x:

Included are notes from the latest major revision to current.

For full documentation please visit:
https://docs.adobe.com/content/help/en/media-analytics/using/sdk-implement/download-sdks.html

## 2.2.5 (5 May, 2021)
What's new :
- Added fix to generate correct Roku OS version string for OS version 10 and above.

## 2.2.4 (13 January, 2021)
What's new :
- Added fix for duplicate Session ID.

## 2.2.3 (16 December, 2019)
What's new :
- Bug fixes to improve stability and SDK performance.

## 2.2.2 (18 September, 2019)
What's new :
- Bug fixes to improve stability and SDK performance.

## 2.2.1 (23 May, 2019)
What's new :
- Added setAdvertisingIdentifier API.
- Added support to save all the custom Identifiers and append it with Analytics hits.
- Bug fixes to improve stability and SDK performance.

## 2.2.0 (7 March, 2019)
What's new :
- Added standard audio metadata for audio analytics support.
- The server endpoint for visitor ID is now configurable via the config file.
- Added buffer events for gaps between Ads during AdBreak.
- Bug fixes to improve stability and SDK performance.

## 2.1.0 (9 August, 2018)
What's new :
- One second ad tracking: Improved accuracy for video ads.
- Improved player state management and error recovery: Additional logic to better support maintaining player states and ensure accurate measurement, including identification of closed state.
- Enhanced input data validation with better debug logging.
- Optimization for session end and addition of new HB "end" event.
- Misc. bug fixes.

API changes:
- Added new APIs for mediaTrackSessionStart and mediaTrackSessionEnd for better media tracking
- Deprecated APIs: mediaTrackLoad, mediaTrackStart, mediaTrackUnload
- Removed ADBVideoPlayer utility for legacy roVideoScreen and roVideoPlayer components

## 2.0.4 (2 March, 2018)
What’s new :
- GDPR compliance
- Remove Eval calls within our SDK for scene graph compatibility.

## 2.0.3 (08 December, 2017)
What’s new :
- Bug fixes

## 2.0.2 (08 September, 2017)
What’s new :
- Added SceneGraph compatibility to AdobeMobileLibrary
- Misc. bug fixes
- API changes: AdobeMobile APIs and Constants have been rewritten into SceneGraph compatible node. For details, refer to the SceneGraph section of the Roku documentation: https://marketing.adobe.com/resources/help/en_US/sc/appmeasurement/hbvideo/roku/c_vhl_sg_titlepage.html

## 2.0.1 (10 April, 2017)
What’s new :
- Added pause tracking feature. Two new heartbeat events are now sent to track pause and stalling.
- Automatic detection of IDLE state. VHL will automatically create a new video tracking session when resuming after a long pause/buffer/stall (after 30 minutes).
- Added new resume heartbeat event. This event is sent to identify scenarios where the playback is a resumed video playback session (e.g.: when playback of a VOD content starts from where the user left it before).
- Misc. bug fixes and stability enhancements


## 2.0.0 (20 June, 2016)
- Added Postbacks feature
- Support for standard Video and Ad metadata
- API Change: Constants for Standard Video and Ad metadata are available on ADBMobile object
- Added video length and video name to the Ad Initiate Adobe Analytics call
- Added heartbeat session id to Adobe analytics calls

## 1.0.2 (4 September, 2015)
- Bug fixes and performance enhancements

## 1.0.1 (24 August, 2015)
- Added support for Federated Analytics in Video heartbeats
- Bug Fixes

## 1.0.0 (10 July, 2015)
- Initial Release to production of version 1.0.0
