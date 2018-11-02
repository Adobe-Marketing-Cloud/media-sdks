# Adobe Media SDK Cocoapods

## Pod Name: AdobeMediaSDK
Downloads MediaSDK v2.2.0+.

For Swift Project, since Cocoapods generates dynamic framework, use 'import AdobeMediaSDK' to include SDK headers.

### Sample Podfile for iOS and tvOS targets using AdobeMediaSDK Pod

    target ‘iOSPodSample’ do
      platform :ios, ‘9.0’
      use_frameworks!
      pod ‘AdobeMediaSDK’
    end

    target ‘TvOSPodSample’ do
      platform :tvos, ‘9.0’
      use_frameworks!
      pod ‘AdobeMediaSDK’
    end


## Pod Name: AdobeVideoHeartbeatSDK
Downloads 2.x Video Heartbeat Libraries prior to v2.2.0.
Important: This Pod will have no further updates post v2.1.0.

### Sample Podfile for iOS and tvOS targets using AdobeVideoHeartbeatSDK Pod

    target 'iOSPodSample' do
      platform :ios, '9.0'
      pod 'AdobeVideoHeartbeatSDK'
    end

    target 'TvOSPodSample' do
      platform :tvos, '9.0'
      pod 'AdobeVideoHeartbeatSDK/TVOS'
    end
