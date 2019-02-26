# MediaExtensionSample (JS)

Documentation for "Adobe Launch" is found [here](https://docs.adobelaunch.com/getting-started).

Documentation for "Adobe Media Analytics for Audio and Video" extension is found [here](https://docs.adobelaunch.com/extension-reference/web/adobe-media-analytics-for-audio-and-video-extension).

Documentation for "Media SDK" is found [here](https://marketing.adobe.com/resources/help/en_US/sc/appmeasurement/hbvideo/).

***Running the sample.***

To run the sample, place the files on a webserver and access the index.html page.

In order to get Media Analytics working in the sample -

1) You need to configure a Launch Web property
2) Add and configure "Experience Cloud ID Service" Extension to your property.
3) Add and configure "Adobe Analytics" Extension to your property.
4) Add and configure "Adobe Media Analytics for Audio and Video" Extension to your property. Make sure to set "Export APIs to Window object" and set variable name to "ADB".
5) Build the library and deploy the script tag synchronously in "index.html" file.