# Release Notes for JavaScript Media SDK 3.x

## 3.0.2 (March 26, 2021)

- Fix "Content-Type" HTTP header in Media Collection API requests. 

## 3.0.1 (October 8, 2020)

- Changed the default ad tracking granularity to 10 seconds. Added configuration key to enable 1 sec ad tracking.
- Restart tracking session every 24 hours for long-running sessions.

## 3.0.0 (April 22, 2020)

- Renamed PlayerState constant CloseCaption to ClosedCaption.
- Minor bug fixes.

## 3.0.0-beta.0 (April 13, 2020)

- Breaking API change : Renamed StandardMetadata and StreamType keys from upper case for consistency.
- Expose standard player state constants.
- Bug fixes around privacy settings.

## 3.0.0-alpha.1 (March 30, 2020)

- Enable tracking using Media Collection APIs.
- Implement player state tracking.

## 3.0.0-alpha.0 (February 14, 2020)

- Breaking API changes from 2.x version of MediaSDK.
- Simplified configuration and tracker creation.
- Added APIs to update playhead and QoE information and to destroy the tracker.
- Simplified setting standard and custom metadata for media and ads.
