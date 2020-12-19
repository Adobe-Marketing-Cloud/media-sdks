# coding: utf-8

Pod::Spec.new do |s|
  s.name         = "AdobeMediaSDK"
  s.version      = "2.3.0"
  s.summary      = "AdobeMediaSDK is Adobe’s standardized Analytics solution for Audio and Video. This is the only official Adobe MediaSDK Pod."
  s.description  = <<-DESC
                    Adobe Analytics for Media enables clients to track the full customer journey across their site, which includes audio and video consumption, and these measures are easily integrated into Analytics reporting and other Experience Cloud products.
                    Adobe MediaSDK was previously known as Adobe VideoHeartbeatLibrary.
                   DESC

  s.homepage     = "https://github.com/Adobe-Marketing-Cloud/media-sdks/releases/tag/ios-v#{s.version}"
  s.documentation_url = "https://docs.adobe.com/content/help/en/media-analytics/using/sdk-implement/setup/set-up-ios.html"

  s.license      = {:type => "Commercial", :text => "Adobe Inc. All Rights Reserved"}
  s.author       = "Adobe Media Analytics SDK Team"
  s.source       = { :git => 'https://github.com/Adobe-Marketing-Cloud/media-sdks.git', :tag => "ios-v#{s.version}-cocoapod"}

  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-all_load' }
  s.cocoapods_version = ">= 1.10"

  s.ios.deployment_target = '8.0'
  s.ios.source_files  = "Empty.m"
  s.ios.vendored_frameworks = "MediaSDK.xcframework"
  s.ios.dependency   "AdobeMobileSDK"

  s.tvos.deployment_target = '9.0'
  s.tvos.source_files  = "Empty.m"
  s.tvos.vendored_frameworks = "MediaSDKTV.xcframework"
  s.tvos.dependency   "AdobeMobileSDK/TVOS"

end
