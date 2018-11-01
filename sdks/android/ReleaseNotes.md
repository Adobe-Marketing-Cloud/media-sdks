# Release Notes for Android Media SDK 2.x
=========================================


Included are notes from the latest major revision to current.

What's new in 2.x:

Lighter, Simpler implementation.
- Streamlined implementation and configuration. With Media SDK 2.x, all the configuration and media tracking API calls are centralized through a single class: MediaHeartbeat.
- Error state recovery. Media SDK 2.x keeps track of the current state of the playback. By having internal state logic, Media SDK 2.x can ignore wrong API calls.
- Clear difference between optional and required media tracking APIs. Optional media tracking features such as chapter tracking, ad tracking, bitrate change, etc. are now tracked through a single media tracking API: trackEvent.

For full documentation, please visit:
https://marketing.adobe.com/resources/help/en_US/sc/appmeasurement/hbvideo/set-up-android.html

For full API documentation, please visit:
https://adobe-marketing-cloud.github.io/media-sdks/reference/android/index.html

## 2.2.0 (November 1, 2018)
- Video Heartbeat Library (VHL) SDK renamed to Media SDK.
- Added standard audio metadata for audio analytics support.
- Added buffer events for buffering between Ads during an AdBreak.
- Bug fixes to improve stability and SDK performance.

## 2.1.0 (February 15, 2018)
- One second ad tracking: Improved accuracy for video ads.
- Improved player state management and error recovery: Additional logic to better support maintaining player states and ensure accurate measurement, including identification of closed state.
- Enhanced input data validation with better debug logging.
- Bug fixes to improve stability and SDK performance.

## 2.0.2 (September 15, 2017)
- Bug fixes to improve memory usage and stability.

## 2.0.1 (June 29, 2017)
- Bug fixes to improve stability and performance.
-
## 2.0.0 (July 15, 2016)
- Initial release of 2.x libraries.
