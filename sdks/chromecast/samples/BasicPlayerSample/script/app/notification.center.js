/*
 * ADOBE SYSTEMS INCORPORATED
 * Copyright 2015 Adobe Systems Incorporated
 * All Rights Reserved.

 * NOTICE:  Adobe permits you to use, modify, and distribute this file in accordance with the
 * terms of the Adobe license agreement accompanying it.  If you have received this file from a
 * source other than Adobe, then your use, modification, or distribution of it requires the prior
 * written permission of Adobe.
 */

(function() {
    'use strict';

    /**
     * A generic event dispatcher.
     *
     * @constructor
     */
    function EventDispatcher() {
        this._events = {};
    }

    /**
     * Register an event-listener method to the event dispatcher.
     *
     * @param {string} name Unique string value identifying the event.
     *
     * @param {Function} listener Function that will be called when the event is dispatched.
     *
     * @param {Object} context Context in which the listener method is called.
     *
     */
    EventDispatcher.prototype.addEventListener = function(name, listener, context) {
        if (!name || !listener) return;
        context = context || window;

        this._events[name] = (this._events[name] || []);
        this._events[name].push({cb: listener, ctx: context});
    };

    /**
     * Un-register an event-listener method to the event dispatcher.
     *
     * NOTE: for an event listener to be removed all the three coordinates must match
     * (name, listener and context) with the values provided during registration.
     *
     * @param {string} name Unique string value identifying the event.
     *
     * @param {Function} listener Function that will be called when the event is dispatched.
     *
     * @param {Object} context Context in which the listener method is called.
     */
    EventDispatcher.prototype.removeEventListener = function(name, listener, context) {
        if (!name || !listener) return;
        context = context || window;

        // Check to see if the event name was registered with us.
        var i, key, isNameRegistered = false;
        for (key in this._events) {
            if (name === key) {
                isNameRegistered = true;
                break;
            }
        }

        // This event name was not registered with us. Just exit.
        if (!isNameRegistered) return;

        // Search for the target event listener
        for (i = this._events[key].length - 1; i >= 0; i--) {
            var _listener = this._events[key][i];
            if (listener === _listener.cb && context === _listener.ctx) {
                this._events[key].splice(i, 1);
            }
        }

        // If we are left with an empty list of listeners for a particular
        // event name, we delete it.
        if (!this._events[key].length) delete this._events[key];
    };

    /**
     * Dispatch en event. It goes through the entire list of listener methods that are registered
     * for the target event and calls that function in the specified context.
     *
     * @param {string} name The name of the event.
     */
    EventDispatcher.prototype.dispatchEvent = function(name) {
        if (!name) return;

        var key, i;
        for (key in this._events) {
            if (this._events.hasOwnProperty(key) && name === key) {
                var listeners = this._events[key],
                    copyOnWrite = listeners.slice(0),
                    length = copyOnWrite.length;

                for (i = 0; i < length; i++) {
                    copyOnWrite[i].cb.call(copyOnWrite[i].ctx);
                }
                break;
            }
        }
    };

    function NotificationCenter() {
        // Provide a singleton EventDispatcher
        if (!NotificationCenter.prototype._instance) {
            NotificationCenter.prototype._instance = new EventDispatcher();
        }

        return NotificationCenter.prototype._instance;
    }

    // Export symbols.
    window.NotificationCenter = NotificationCenter;
})();
