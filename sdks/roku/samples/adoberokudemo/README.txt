The videoplayer example demonstrates a hierarchical,
category based video playback application. The
application allows the playback of a selection 
of TED Talks videos which are organized by category.
  
The application uses a category based XML feed 
to drive the application. The XML describes all
of the categories used, artwork required and
videos to be played. The hierarchy of categories 
is described in the file categories.xml.  
The actual XML request/response uses our servers, 
but the XML is all included for reference.

Each category branch node, ultimately terminates at a 
leaf node that lists details for all of the videos 
included in that category. The XML for the leaf 
nodes is also included and named in the format 
<category>.xml.

It is possible to easily use this as a template 
for a production application by implementing the 
appropriate web service API's to provide the 
category and content XML feeds. You must also
provide the artwork and brand specific assets 
appropriate for your application.

Contents of the application directories are:

images   - Artwork that is embedded as part of 
           the application. In general, this 
           should be kept to a minimum to conserve 
           space on flash, and is usually just the 
           main menu icons, plus the logo and 
           overhang used for branding.
source   - The complete BrightScript source code 
           for the application
xml      - Examples of the XML returned by the 
           server for reference
artwork  - Examples of the artwork returned by the 
           server for reference.  
manifest - This file describes the application 
           package and is used on the main menu 
           prior to the start of execution for the 
           application.
Makefile - Optional method of building the application 
           using "make". This has been provided for 
           convenience and tested on OSX and linux.


Note: The xml and artwork directories are NOT part of the application
      package, but can be saved as an archive using the "make archive"
      target. The makefile also can push the development app directly
      to the device if "make" and "curl" are available. See the comments
      in the Makefile for more information.

      **************************************************