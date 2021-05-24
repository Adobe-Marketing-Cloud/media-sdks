# Android - Getting Started

## Prerequisites

- Android Studio 3.+ with an Android emulator running Android 7.0+
- Gradle 4.10.1+

## How to run the project

1. Navigate to the `android/` directory and open the `build.gradle` file as a project in Android Studio.
2. Sync the gradle project to download the required dependencies.
3. `BasicSamplePlayer` is a simple app used to showcase the `Media Analytics for Audio and Video` extension with the Adobe Mobile SDK
4. If you want to run the test app, do the following:
   Configured mobile property in Launch, then in `MediaAnalyticsTestApp.java`, fill in the value of "LAUNCH_ENVIRONMENT_FILE_ID" with your environment ID
    - Select the `BasicSamplePlayer` Run Configuration and press `Run`

Doc: https://aep-sdks.gitbook.io/docs/using-mobile-extensions/adobe-media-analytics

## Run with Assurance extension
Assurance support is added to the sample app.  
To run with Assurance:
- Add Assurance extension to the mobile property in Launch
- Setup Assurance Session with Base URL: basicplayersample://   
(Which is the deeplink of the sample app)

Options to access Assurance
1. Scan QR Code  (Need to install the app to the device first)
or
2. Copy Link from Assurance and enter it into the "Enter Assurance Url" field and click "SET ASSURANCE" button in the sample app.

Doc: https://aep-sdks.gitbook.io/docs/beta/project-griffon