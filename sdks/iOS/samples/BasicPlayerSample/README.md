BasicPlayerSample (iOS)
==========================

1. Opening the project
To open the project, you use the XCode IDE. Load the project from the project/ folder.

2. Building and running
The project embeds the required libraries and assets, so you should be able to build in the IDE.

To run the sample, just press the play button inside XCode. The sample should work fine in the simulator.

The sample comes with dummy values for all the configuration options (see Configuration.m and the ADBMobileConfig.json configuration files). 

In order to actually see the demo working, you need to fill-in the configuration options with valid values, provided by Adobe.


Implementation details
======================

This is a sample video player application whose main goal is to demostrate the video-tracking capabilities of Adobe's VideoHeartbeat SDK for iOS consisting in:
    - pure playback tracking.
    - ad tracking.
    - chapter tracking.

The application is defines a "video player" object which is nothing more than a thin wrapper over the iOS native video-playback control (it extends MPMoviePlayerController). It automatically loads a pre-defined video asset with a length of 60 seconds. This video asset is segmented into a sequence of 2 chapters and one ad as follows:
    - a first chapter of 15 seconds (0-15)
    - an ad of 15 seconds (15-30)
    - a second chapter of 30 seconds (30-60)

Below is a graphic representation of the asset timeline:

    |     CH 1    |      AD     |           CH 2           |
    |-------------|+++++++++++++|--------------------------|
    0            15            30                         60
                   
The VideoPlayer instance exposes a series of events which are captured by the VideoAnalyticsProvider class and translated into direct calls into the public API VideoHeartbeat library. This is the basic recommened integration pattern for the Videoheartbeat SDK. The VideoPlayerDelegate custom implementation of the PlayerDelegate interface queries the VideoPlayer for the various information that needs to be extracted from the player itself in order to implement a full video-tracking workflow.          