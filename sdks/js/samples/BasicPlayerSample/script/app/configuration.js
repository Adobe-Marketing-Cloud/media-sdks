/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2014 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */

(function() {
    'use strict';

    // Export symbols.
    window.Configuration = {
        PLAYER: {
            NAME: 'HTML5 basic media player',
            VIDEO_ID: 'clickbaby',
			VIDEO_NAME: 'sample video click-baby'
        },

        VISITOR: {
            MARKETING_CLOUD_ORG_ID: 'sample-marketing-cloud-org-id',
            TRACKING_SERVER: 'example.com',
            DPID: 'sample-dpid',
            DPUUID: 'sample-dpuuid'
        },

        APP_MEASUREMENT: {
            RSID: 'sample-account',
            TRACKING_SERVER: 'example.com',
			PAGE_NAME: 'Sample Page Name'
        },

        HEARTBEAT: {
            TRACKING_SERVER: 'example.com',
            PUBLISHER: 'sample-publisher',
            CHANNEL: 'sample-channel',
            OVP: 'sample-ovp',
            SDK: 'sample-sdk'
        }
    };
})();
