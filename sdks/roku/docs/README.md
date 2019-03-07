AdobeMobilelibrary SceneGraph support for Roku SceneGraph applications
======================================================================

Adobe mobile sdk is written in brightscript and uses a lot of components unavailable on an app running on SceneGraph (thread). Therefore, a roku app developer intending to use SceneGraph framework cannot call Adobe Mobile SDK APIs similar to traditional brightscript apps. To setup SceneGraph support for AdobeMobileLibrary into your application, follow the steps below to configure the project.


Download AdobeMobileLibrary with SceneGraph support
---------------------------------------------------
1. Download the library from https://github.com/Adobe-Marketing-Cloud/media-sdks/releases
2. Copy adbmobile.brs (AdobeMobileLibrary) inside the pkg:/source/ directory.
3. For Scene Graph support, copy adbmobileTask.brs and adbMobileTask.xml into your pkg:/components/ directory.
4. Import adbmobile.brs into your Scene - refer documentation for more details
5. Create instance of adbmobileTask node into your Scene - refer documentation for more details
6. Get an instance of adbmobile connector for SceneGraph using the adbmobileTask instance - refer documentation for more details
7. Start using the adbmobile APIs available on connector instance - refer documentation for more details