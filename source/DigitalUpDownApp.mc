using Toybox.Application as App;
using Toybox.Background as Bg;
import Toybox.Lang;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application.Storage as Prop;

// In-memory current location.
// Previously persisted in App.Storage, but now persisted in Object Store due to #86 workaround for App.Storage firmware bug.
// Current location retrieved/saved in checkPendingWebRequests.
// Persistence allows weather and sunrise/sunset features to be used after watch face restart, even if watch no longer has current
// location available.
var gLocationLat, gLocationLng;

var gField1Type = "0",
    gField2Type = "5",
    gField3Type = "6";

(:background)
class DigitalUpDownApp extends App.AppBase {
    var mView;

    function initialize() {
        App.AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {}

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {}

    // Return the initial view of your application here
    function getInitialView() as Array<Ui.Views or Ui.InputDelegates>? {
        mView = new DigitalUpDownView();
        onSettingsChanged(); // After creating view.
        return [mView] as Array<Ui.Views or Ui.InputDelegates>;
    }

    function getIntProperty(key, defaultValue) {
        var value = Prop.getValue(key);
        if (value == null) {
            value = defaultValue;
        } else if (!(value instanceof Number)) {
            value = value.toNumber();
        }
        return value;
    }

    function getLogHeader() {
        var myTime = System.getClockTime();
        return (
            "[" +
            myTime.hour.format("%02d") +
            ":" +
            myTime.min.format("%02d") +
            ":" +
            myTime.sec.format("%02d") +
            "] "
        );
    }

    // New app settings have been received so trigger a UI update
    function onSettingsChanged() {
        gField1Type = getIntProperty("Field1", 0);
        gField2Type = getIntProperty("Field2", 5);
        gField3Type = getIntProperty("Field3", 6);

        mView.onSettingsChanged(); // Calls checkPendingWebRequests.

        Ui.requestUpdate();
    }

    function hasField(fieldType) {
        return (
            gField1Type == fieldType ||
            gField2Type == fieldType ||
            gField3Type == fieldType
        );
    }

    (:background_method)
    function getServiceDelegate() {
        return [new BackgroundService()];
    }

    // Determine if any web requests are needed.
    // If so, set approrpiate pendingWebRequests flag for use by BackgroundService, then register for
    // temporal event.
    // Currently called on layout initialisation, when settings change, and on exiting sleep.
    (:background_method)
    function checkPendingWebRequests() {
        // Attempt to update current location, to be used by Sunrise/Sunset, and Weather.
        // If current location available from current activity, save it in case it goes "stale" and can not longer be retrieved.
        var location = Activity.getActivityInfo().currentLocation;
        Sys.println(
            getLogHeader() + ">>> checkPendingWebRequests started" + location
        );
        if (location) {
            location = location.toDegrees(); // Array of Doubles.
            gLocationLat = location[0].toFloat();
            gLocationLng = location[1].toFloat();

            Application.Storage.setValue("LastLocationLat", gLocationLat);
            Application.Storage.setValue("LastLocationLng", gLocationLng);

            // If current location is not available, read stored value from Object Store, being careful not to overwrite a valid
            // in-memory value with an invalid stored one.
        } else {
            var lat = Application.Storage.getValue("LastLocationLat");
            if (lat != null) {
                gLocationLat = lat;
            }

            var lng = Application.Storage.getValue("LastLocationLng");
            if (lng != null) {
                gLocationLng = lng;
            }
        }

        if (!(Sys has :ServiceDelegate)) {
            Sys.println("<<< checkPendingWebRequests end (No ServiceDelegate)");
            return;
        }

        var pendingWebRequests =
            Application.Storage.getValue("PendingWebRequests");
        if (pendingWebRequests == null) {
            pendingWebRequests = {};
        }

        // Weather:
        // Location must be available, weather or humidity data field must be shown.
        if (gLocationLat != null && hasField(FIELD_TYPE_HUMIDITY)) {
            var owmCurrent = Application.Storage.getValue(
                "OpenWeatherMapCurrent"
            );

            Sys.println(
                getLogHeader() +
                    "Weather: " +
                    gLocationLat +
                    ", " +
                    gLocationLng +
                    ", " +
                    owmCurrent
            );

            pendingWebRequests["OpenWeatherMapCurrent"] = true;
        }

        // If there are any pending requests:
        if (pendingWebRequests.keys().size() > 0) {
            Sys.println(
                getLogHeader() +
                    "Pending requests: " +
                    pendingWebRequests.keys().toString()
            );
            // Register for background temporal event as soon as possible.
            var lastTime = Bg.getLastTemporalEventTime();
            if (lastTime) {
                // Events scheduled for a time in the past trigger immediately.
                var nextTime = lastTime.add(new Time.Duration(5 * 60));
                // var nextTime = lastTime.add(new Time.Duration(5));
                Bg.registerForTemporalEvent(nextTime);
                Sys.println(
                    getLogHeader() +
                        "Next event scheduled for: " +
                        nextTime.toString()
                );
            } else {
                Bg.registerForTemporalEvent(Time.now());
                Sys.println(getLogHeader() + "Next event scheduled for: now");
            }
        }

        Application.Storage.setValue("PendingWebRequests", pendingWebRequests);

        Sys.println("<<< checkPendingWebRequests end");
    }

    // Handle data received from BackgroundService.
    // On success, clear appropriate pendingWebRequests flag.
    // data is Dictionary with single key that indicates the data type received. This corresponds with Object Store and
    // pendingWebRequests keys.
    (:background_method)
    function onBackgroundData(data) {
        var pendingWebRequests =
            Application.Storage.getValue("PendingWebRequests");
        if (pendingWebRequests == null) {
            Sys.println(
                "onBackgroundData() called with no pending web requests!"
            );
            pendingWebRequests = {};
        }

        var type = data.keys()[0]; // Type of received data.
        var storedData = Application.Storage.getValue(type);
        var receivedData = data[type]; // The actual data received: strip away type key.

        Sys.println(
            getLogHeader() +
                "onBackgroundData() received " +
                type +
                " data: " +
                receivedData
        );

        // No value in showing any HTTP error to the user, so no need to modify stored data.
        // Leave pendingWebRequests flag set, and simply return early.
        if (receivedData["httpError"]) {
            return;
        }

        // New data received: clear pendingWebRequests flag and overwrite stored data.
        storedData = receivedData;
        pendingWebRequests.remove(type);
        Application.Storage.setValue("PendingWebRequests", pendingWebRequests);
        Application.Storage.setValue(type, storedData);

        Ui.requestUpdate();
    }
}

function getApp() as DigitalUpDownApp {
    return App.getApp() as DigitalUpDownApp;
}
