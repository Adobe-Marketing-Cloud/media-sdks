# Release Notes for JavaScript VideoHeartbeat 2.x SDK

Included are notes from the latest major revision to current.

What's new in 2.x:

Lighter, Simpler implementation.
	- Streamlined implementation and configuration. With VHL 2.x, all the configuration and video tracking API calls are centralized through a single class: MediaHeartbeat.
	- Error state recovery. VHL 2.x keeps track of the current state of the playback. By having internal state logic, VHL 2.x can ignore wrong API calls.
	- Clear difference between optional and required video tracking APIs. Optional video tracking features such as chapter tracking, ad tracking, bitrate change, etc. are now tracked through a single video tracking API: trackEvent.

For full documentation please visit:
https://marketing.adobe.com/resources/help/en_US/sc/appmeasurement/hbvideo/js_2.0/

## 2.0.2
- Bug fixes.

## 2.0.1
- Fixed issues with adding custom video metadata on Firefox 47.0 and Chrome 52.0.

## 2.0.0
- Initial release of 2.x libraries.
