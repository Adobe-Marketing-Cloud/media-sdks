# Cast-Player-Sample (reference receiver app)

This sample shows how to develop a fully Cast Design Checklist compliant receiver.

**This is a reference receiver app to be used as the starting point for your custom receiver**

**NOTE: The receiver code refers to the Autoplay UI logic as "PreviewMode" since the reference receiver already supports a playback feature called "autoplay".**

Here is the list of other reference apps:
* [Android Sender: CastVideos-android](https://github.com/googlecast/CastVideos-android)
* [iOS Sender: CastVideos-ios](https://github.com/googlecast/CastVideos-ios)
* [Chrome Sender: CastVideos-chrome](https://github.com/googlecast/CastVideos-chrome)

## Setup Instructions
* Get a Chromecast device
* Upload the project to a website that can be accessed from your Chromecast. Later, when you publish your application, you will need to host so that it is accessible using HTTPS.
* Register an application on the Developers Console (http://cast.google.com/publish). Enter the URL for the player.html. There is a button marked publish, if you set that, then your receiver can be accessed by all devices, but it requires that you be serving using https.  Not publishing your app, lets you restrict the receiver to devices that you specify and allows you to host on most development servers.
* If you haven't already done so, please register the serial # of your Chromecast device in the developer console as well.
* Using the Chromecast setup application, make sure [x] send your serial number to Google is checked.  This is the only way that you can access your unpublished receiver.  While you are in the Setup application, make a note of the IP address of your Chromecast. It will be helpful later if you wish to use the Chrome Remote Debugger.
* 15 minutes after you have updated the developers console, you should reboot your Chromecast, so that it picks up the changes.
* Enter the App ID of your receiver application into your sender application or one of our sample sender applications, such as DemoCastPlayer.
* You should now be able to launch your receiver using a sender.
* If you wish to watch whats going on, using a Chrome browser, connect to &lt;IP of your Chromecast>:9222 and debug your receiver.  A good place to start is looking at the console log.

## References and How to report bugs
* [Cast Developer Documentation](http://developers.google.com/cast/)
* [Receiver Apps](https://developers.google.com/cast/docs/receiver_apps)
* [Media Player Library Reference](http://developers.google.com/cast/docs/player)
* [Receiver Reference](https://developers.google.com/cast/docs/reference/receiver/)
* [Design Checklist](https://developers.google.com/cast/docs/design_checklist)
* If you find any issues with this sample, please open a bug here on GitHub
* Questions are answered on [StackOverflow](http://stackoverflow.com/questions/tagged/google-cast)
* [Google Cast Issue Tracker](https://code.google.com/p/google-cast-sdk/)

## How to make contributions?
Please read and follow the steps in the CONTRIBUTING.md

## License
See LICENSE

## Google+
 Google Cast Developers Community on Google+ [http://goo.gl/TPLDxj](http://goo.gl/TPLDxj)
