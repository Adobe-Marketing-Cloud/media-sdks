# Release Notes for iOS Media SDK 2.x

Included are notes from the latest major revision to current.

What's new in 2.x:

Lighter, Simpler implementation.
    - Streamlined implementation and configuration. With Media SDK 2.x, all the configuration and media tracking API calls are centralized through a single class: ADBMediaHeartbeat.
    - Error state recovery. Media SDK 2.x keeps track of the current state of the playback. By having internal state logic, Media SDK 2.x can ignore wrong API calls.
    - Clear difference between optional and required media tracking APIs. Optional media tracking features such as chapter tracking, ad tracking, bitrate change, etc. are now tracked through a single media tracking API: trackEvent:.

For full documentation please visit:
https://marketing.adobe.com/resources/help/en_US/sc/appmeasurement/hbvideo/sdk-implement.html

## 2.3.0 (December 18, 2020)
- General - The SDK is now distributed using XCFrameworks in order to support hardware with the new Apple M1 architecture while maintaining support for existing Intel architecture.
  - **IMPORTANT**: Upgrading to MediaSDK XCFrameworks requires Xcode 12.0 or newer
  - **IMPORTANT**: If using Cocoapods, upgrading to MediaSDK XCFrameworks requires Cocoapods 1.10.0 or newer
  
## 2.2.8 (December 1, 2020)
- Fix race conditions to improve SDK stability.

## 2.2.7 (January 15, 2020)
- Fix race conditions to improve SDK stability.

## 2.2.6 (September 26, 2019)
- Bug fixes to improve stability and performance.

## 2.2.5 (August 16, 2019)
- Bug fixes to improve stability and performance.

## 2.2.4 (June 20, 2019)
- Bug fixes to improve stability and SDK performance.

## 2.2.3 (April 3, 2019)
- Bug fix in parsing error code for trackError API.

## 2.2.2 (February 22, 2019)
- Fix User-Agent string in http requests.

## 2.2.1 (February 14, 2019)
- Bug fix around custom metadata for Ads.

## 2.2.0 (November 1, 2018)
- Video Heartbeat Library (VHL) SDK renamed to Media SDK.
- Added standard audio metadata for audio analytics support.
- Added buffer events for gaps between Ads during AdBreak.
- Fixed dependency of executing APIs on main thread.
- Bug fixes to improve stability and SDK performance.

## 2.1.0 (February 15, 2018)
- One second ad tracking: Improved accuracy for video ads.
- Improved player state management and error recovery: Additional logic to better support maintaining player states and ensure accurate measurement, including identification of closed state.
- Enhanced input data validation with better debug logging.
- Bug fixes to improve stability and SDK performance.

## 2.0.1 (11 Oct, 2016)
What’s new :
- Bug fixing to improve stability and performance.

## 2.0.0 (July 15, 2016)
- Initial release of 2.x libraries.
