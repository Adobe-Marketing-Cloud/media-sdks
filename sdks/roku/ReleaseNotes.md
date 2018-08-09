# Release Notes for BrightScript (Roku) Adobe Mobile Library version 2.x:

Included are notes from the latest major revision to current.

For full documentation please visit:
https://marketing.adobe.com/resources/help/en_US/sc/appmeasurement/hbvideo/roku/

## 2.1.0 (9 August, 2018)
What's new :
- One second ad tracking: Improved accuracy for video ads.
- Improved player state management and error recovery: Additional logic to better support maintaining player states and ensure accurate measurement, including identification of closed state.
- Enhanced input data validation with better debug logging.
- Optimization for session end and addition of new HB "end" event.
- Misc. bug fixes.

API changes:
- Added new APIs for mediaTrackSessionStart and mediaTrackSessionEnd for better media tracking
- Deprecated APIs: mediaTrackLoad, mediatrackStart, mediaTrackUnload
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
