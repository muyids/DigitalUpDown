using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian;
using Toybox.Activity as Activity;
using Toybox.Weather as Weather;
using Toybox.Position as Position;
using Toybox.SensorHistory;

enum /* FIELD_TYPES */ {
    // Pseudo-fields.
    FIELD_TYPE_PSEUDO_TIME = -1,

    // Real fields (used by properties).
    FIELD_TYPE_HEART_RATE = 0,
    FIELD_TYPE_BATTERY = 1,
    FIELD_TYPE_STEPS = 5,
    FIELD_TYPE_UPSTAIRS = 6,
    FIELD_TYPE_CALORIES = 7,
    FIELD_TYPE_BODY_BATTERY = 8,
    FIELD_TYPE_PRESSURE = 9,
    FIELD_TYPE_ACTIVE_MINUTES = 10,
    FIELD_TYPE_DISTANCE = 11,
    FIELD_TYPE_SUNRISE = 12,
    FIELD_TYPE_SUNSET = 13,
    FIELD_TYPE_PULSE_OX = 14,
    FIELD_TYPE_SEDENTARY_REMINDER = 15,
    FIELD_TYPE_NOTIFICATION = 16,
    FIELD_TYPE_ALARMS = 17,
    FIELD_TYPE_HUMIDITY = 18,
    FIELD_TYPE_SOLAR_INTENSITY = 19,
    FIELD_TYPE_ALTITUDE = 20,
    FIELD_TYPE_PM25 = 21,
    FIELD_TYPE_RECOVERY_TIME = 22,
    FIELD_TYPE_THERMOMETER = 23,
}

class RightArea extends Ui.Drawable {
    private var locX, locY, width, height;
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

    // get the SensorHistoryIterator object
    function getBodyBattery() {
        // Check device for SensorHistory compatibility
        if (
            Toybox has :SensorHistory &&
            Toybox.SensorHistory has :getBodyBatteryHistory
        ) {
            // Set up the method with parameters
            var bbIterator = Toybox.SensorHistory.getBodyBatteryHistory({});
            return bbIterator ? bbIterator.next().data.toNumber() : "--";
        }
        return null;
    }

    // get the SensorHistoryIterator object
    function getPressure() {
        // Check device for SensorHistory compatibility
        if (
            Toybox has :SensorHistory &&
            Toybox.SensorHistory has :getPressureHistory
        ) {
            var pIterator = Toybox.SensorHistory.getPressureHistory({});
            return pIterator ? pIterator.next().data.toNumber() / 1000 : "--";
        }
        return null;
    }

    function getOxygenSaturation() {
        if (
            Toybox has :SensorHistory &&
            Toybox.SensorHistory has :getOxygenSaturationHistory
        ) {
            var o2Iterator = Toybox.SensorHistory.getOxygenSaturationHistory(
                {}
            );
            return o2Iterator ? o2Iterator.next().data.toNumber() : "--";
        }
        return null;
    }

    function initialize(params) {
        Drawable.initialize(params);
        self.locX = params[:locX];
        self.locY = params[:locY];
        self.width = params[:width];
        self.height = params[:height];
    }

    function draw(dc as Gfx.Dc) {
        drawField(dc, getFieldType(gField1Type), getFieldVal(gField1Type), -1);
        drawField(dc, getFieldType(gField2Type), getFieldVal(gField2Type), 0);
        drawField(dc, getFieldType(gField3Type), getFieldVal(gField3Type), 1);
    }

    private var iconArray = [
        "A",
        "B",
        "C",
        "D",
        "E",
        "F",
        "G",
        "H",
        "I",
        "J",
        "K",
        "L",
        "M",
        "N",
    ];

    function getFieldType(fieldIcon) {
        if (fieldIcon < 10) {
            return fieldIcon;
        }
        return iconArray[fieldIcon - 10];
    }

    function _getLocalTime(
        location as Position.Location,
        moment as Time.Moment
    ) {
        var localMoment = Gregorian.localMoment(location, moment);
        var info = Gregorian.info(localMoment, Time.FORMAT_SHORT);
        return Lang.format("$1$:$2$", [
            info.hour.format("%02u"),
            info.min.format("%02u"),
        ]);
    }

    function getFieldVal(fieldIcon) {
        var info = ActivityMonitor.getInfo();
        var activityInfo = Activity.getActivityInfo();
        var location;
        var today = new Time.Moment(Time.today().value());
        if (
            fieldIcon.toString() == "1" ||
            fieldIcon.toString() == "2" ||
            fieldIcon.toString() == "3" ||
            fieldIcon.toString() == "4"
        ) {
            return Lang.format("$1$%", [Sys.getSystemStats().battery.toLong()]);
        }
        var weather;
        var weatherValue;
        var sunsetMoment, sunriseMoment;
        var value = "--";
        switch (fieldIcon) {
            case FIELD_TYPE_HEART_RATE:
                value = activityInfo.currentHeartRate;
                break;
            case FIELD_TYPE_STEPS:
                value = info.steps;
                break;
            case FIELD_TYPE_UPSTAIRS:
                value = info.floorsClimbed;
                break;
            case FIELD_TYPE_CALORIES:
                value = info.calories;
                break;
            case FIELD_TYPE_BODY_BATTERY:
                value = getBodyBattery();
                break;
            case FIELD_TYPE_PRESSURE:
                value = getPressure();
                break;
            case FIELD_TYPE_ACTIVE_MINUTES:
                value = info.activeMinutesWeek.total;
                break;
            case FIELD_TYPE_DISTANCE:
                value = info.distance / 100;
                break;
            case FIELD_TYPE_PULSE_OX:
                value = getOxygenSaturation();
                break;
            case FIELD_TYPE_SEDENTARY_REMINDER:
            case FIELD_TYPE_NOTIFICATION:
            case FIELD_TYPE_ALARMS:
            case FIELD_TYPE_SOLAR_INTENSITY:
            case FIELD_TYPE_ALTITUDE:
                break;
            case FIELD_TYPE_SUNRISE:
            case FIELD_TYPE_SUNSET:
                if (gLocationLat == null) {
                    break;
                }
                location = new Position.Location({
                    :latitude => gLocationLat,
                    :longitude => gLocationLng,
                    :format => :degrees,
                });

                // if current time is am, show sunrise time, else show sunset time
                sunriseMoment = Weather.getSunrise(location, Time.now());
                if (System.getClockTime().hour < 12) {
                    value = _getLocalTime(location, sunriseMoment);
                } else {
                    sunsetMoment = Weather.getSunset(location, Time.now());
                    value = _getLocalTime(location, sunsetMoment);
                }
                break;
            case FIELD_TYPE_PM25:
            case FIELD_TYPE_HUMIDITY:
            case FIELD_TYPE_THERMOMETER:
                weather = App.Storage.getValue("OpenWeatherMapCurrent");
                if (gLocationLat == null) {
                    value = "--";
                } else if (weather != null) {
                    if (fieldIcon == FIELD_TYPE_HUMIDITY) {
                        weatherValue = weather["humidity"];
                        value = weatherValue.format(INTEGER_FORMAT) + "%";
                    } else if (fieldIcon == FIELD_TYPE_THERMOMETER) {
                        weatherValue = weather["temp"] / 10;
                        value = weatherValue.format(INTEGER_FORMAT) +";";
                    }
                } else if (App has :Storage &&
                    App.Storage.getValue("PendingWebRequests") != null &&
                    App.Storage.getValue("PendingWebRequests")[
                        "OpenWeatherMapCurrent"
                    ] != null
                ) {
                    value = "--";
                }
                break;
            case FIELD_TYPE_RECOVERY_TIME:
                break;
            default:
                value = "--";
                break;
        }
        if (value == null) {
            value = "--";
        }
        return value.toString();
    }

    function drawField(dc, fieldIcon, value, index) {
        var iconWidth = dc.getTextWidthInPixels(
            fieldIcon.toString(),
            _fMetricsIcon
        );
        dc.setColor(gIconColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            locX + iconWidth / 2,
            gHeight / 2 + _hMetricsFont * index,
            _fMetricsIcon,
            fieldIcon,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(gFontColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            locX + iconWidth + dc.getTextWidthInPixels(value, _fMetricsFont),
            gHeight / 2 + _hMetricsFont * index,
            _fMetricsFont,
            value,
            Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}
