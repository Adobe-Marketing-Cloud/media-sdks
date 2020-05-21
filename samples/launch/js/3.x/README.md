# Adobe Media Analytics (3.x SDK) for Audio and Video Extension

Documentation for "Adobe Launch" is found [here](https://docs.adobe.com/content/help/en/launch/using/intro/get-started/quick-start.html).

Documentation for "Adobe Media Analytics (3.x SDK) for Audio and Video" extension is found [here](https://docs.adobe.com/content/help/en/launch/using/extensions-ref/adobe-extension/media-analytics-3x-extension/overview.html).

Documentation for "Media SDK" is found [here](https://adobe-marketing-cloud.github.io/media-sdks/reference/javascript_3x/index.html).

## Running the sample

1) To run the sample, place the files on a webserver and access the index.html page.
2) To get Media Analytics working in the sample:
    - You need to configure a Launch Web property
    - Add and configure "Experience Cloud ID Service" Extension to your property.
    - Add and configure "Adobe Analytics" Extension to your property.
    - Add and configure "Adobe Media Analytics (3.x SDK) for Audio and Video" Extension to your property. Make sure to set "Export APIs to Window object" and set variable name to "ADB".
    - Currently for this sample to work, build the library and deploy the script tag synchronously in "index.html" file. Follow this [link](https://docs.adobe.com/content/help/en/launch/using/reference/publish/environments.html) to learn about embedding launch code in your web page.
