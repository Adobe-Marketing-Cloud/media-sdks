Pod::Spec.new do |s|
  s.name         = "AdobeVideoHeartbeatSDK"
  s.version      = "2.0.1"
  s.summary      = "Video Analytics (Heartbeats) is Adobe’s standardized video solution. This is the only official Adobe Video Analytics (Heartbeats) Pod."
  s.description  = <<-DESC
                   Adobe Analytics for Video enables clients to track the full customer journey across their site, which includes video consumption, and these measures are easily integrated into Analytics reporting and other Experience Cloud products.
                   DESC

  s.homepage     = "https://github.com/Adobe-Marketing-Cloud/video-heartbeat-v2/releases"

  s.license      = {:type => "Commercial", :text => "Adobe Systems Incorporated All Rights Reserved"}
  s.author       = "Adobe Video Heartbeat Library Team"
  s.source       = { :git => 'https://github.com/Adobe-Marketing-Cloud/video-heartbeat-v2.git', :tag => "ios-v2.0.1-cocoapod" }
  s.platform     = :ios, '5.0'
  

  s.default_subspec = 'iOS'
  
  s.subspec 'iOS' do |ios|
    ios.frameworks = "UIKit", "SystemConfiguration"
    ios.libraries = "sqlite3.0"
    ios.source_files  = "libs/Headers/*.h"
    ios.vendored_libraries = "libs/libVideoHeartbeat.a"
    ios.dependency   "AdobeMobileSDK"
  end

  s.subspec 'TVOS' do |tvos|
    tvos.platform  = :tvos, '9.0'
    tvos.tvos.deployment_target = '9.0'
    tvos.frameworks = "UIKit", "SystemConfiguration"
    tvos.libraries = "sqlite3.0"
    tvos.source_files  = 'libs/Headers/*.h'
    tvos.vendored_libraries = 'libs/libVideoHeartbeat_TV.a'
    tvos.dependency   "AdobeMobileSDK/TVOS"
  end
  
end