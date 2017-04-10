# Release Notes for BrightScript (Roku) Adobe Mobile Library version 2.x:

Included are notes from the latest major revision to current.

For full documentation please visit:
https://marketing.adobe.com/resources/help/en_US/sc/appmeasurement/hbvideo/roku/

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
