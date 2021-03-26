# Release Notes for Adobe Mobile Library (Chromecast):

Included are notes from the latest major revision to current.

For full documentation please visit:
https://docs.adobe.com/content/help/en/media-analytics/using/sdk-implement/setup/set-up-chromecast.html

## 3.0.2 (March 26, 2021)
What's new :
- Fix "Content-Type" HTTP header in Media Collection API requests. 

## 3.0.1 (8 October, 2020)
What's new :
- Changed the default ad tracking granularity to 10 seconds. Added configuration key to enable 1 sec ad tracking.
- Restart tracking session every 24 hours for long-running sessions.

## 3.0.0 (14 August, 2020)
What's new :
- Breaking change - 3.x SDK uses collection API endpoint for media tracking. Make sure to update "mediaHeartbeat.server" in ADBMobileConfig to correct endpoint. Contact your adobe representative for more information.
- Removed deprecated APIs from earlier version.
- Implement player state tracking.
- Expose standard player state constants
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

## 2.0.2 (2 March, 2018)
What’s new :
- GDPR compliance

## 2.0.1 (22 November, 2017)
What’s new :
- Bug fixes

## 2.0.0 (11 August, 2017)
What’s new :
- Added new tracking APIs and constants to make the library consistent with other platforms. 
- Added pause tracking feature. Two new heartbeat events are now sent to track pause and stalling.
- Automatic detection of IDLE state. VHL will automatically create a new video tracking session when resuming after a long pause/buffer/stall (after 30 minutes).
- Added new resume heartbeat event. This event is sent to identify scenarios where the playback is a resumed video playback session (e.g.: when playback of a VOD content starts from where the user left it before).
- Added Postbacks feature
- Added heartbeat session id to Adobe analytics calls
- Misc. bug fixes and stability enhancements


## 1.0.0 (10 February, 2016)
- Initial Release to production of version 1.0.0
