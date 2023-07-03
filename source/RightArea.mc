using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Activity as Activity;

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
    FIELD_TYPE_WEATHER = 30,
}

class RightArea extends Ui.Drawable {
    private var locX, locY, width, height;

    function initialize(params) {
        Drawable.initialize(params);
        self.locX = params[:locX];
        self.locY = params[:locY];
        self.width = params[:width];
        self.height = params[:height];
    }

    function draw(dc) {
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

    function getFieldType(fieldType) {
        if (fieldType < 10) {
            return fieldType;
        }
        return iconArray[fieldType - 10];
    }

    function getFieldVal(fieldType) {
        var info = ActivityMonitor.getInfo();
        var activityInfo = Activity.getActivityInfo();
        var battery = "";
        if (
            fieldType.toString() == "1" ||
            fieldType.toString() == "2" ||
            fieldType.toString() == "3" ||
            fieldType.toString() == "4"
        ) {
            battery = Lang.format("$1$%", [
                Sys.getSystemStats().battery.toLong(),
            ]);
        }
        var weather;
        var weatherValue;
        var value = "...";
        switch (fieldType) {
            case FIELD_TYPE_HEART_RATE:
                value = activityInfo.currentHeartRate;
                break;
            case FIELD_TYPE_BATTERY:
                value = battery;
                break;
            case FIELD_TYPE_BATTERY:
                value = battery;
                break;
            case FIELD_TYPE_BATTERY:
                value = battery;
                break;
            case FIELD_TYPE_BATTERY:
                value = battery;
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
                break;
            case FIELD_TYPE_PRESSURE:
                // value = gField9Val;
                break;
            case FIELD_TYPE_ACTIVE_MINUTES:
                value = info.activeMinutesWeek.total;
                break;
            case FIELD_TYPE_DISTANCE:
                value = info.distance / 100;
                break;

            case FIELD_TYPE_PULSE_OX:
                // value = gField5Val;
                break;
            case FIELD_TYPE_SEDENTARY_REMINDER:
                // value = gField6Val;
                break;
            case FIELD_TYPE_NOTIFICATION:
                // value = gField7Val;
                break;
            case FIELD_TYPE_ALARMS:
            // value = gField8Val;

            case FIELD_TYPE_SOLAR_INTENSITY:
                // value = gField10Val;
                break;
            case FIELD_TYPE_ALTITUDE:
                // value = gField11Val;
                break;
            case FIELD_TYPE_WEATHER:
            case FIELD_TYPE_SUNRISE:
            case FIELD_TYPE_SUNSET:
            case FIELD_TYPE_PM25:
            case FIELD_TYPE_HUMIDITY:
                weather = App.Storage.getValue("OpenWeatherMapCurrent");
                // Awaiting location.
                if (gLocationLat == null) {
                    value = "gps?";

                    // Stored weather data available.
                } else if (weather != null) {
                    // FIELD_TYPE_HUMIDITY.
                    if (fieldType == FIELD_TYPE_HUMIDITY) {
                        weatherValue = weather["humidity"];
                        value = weatherValue.format(INTEGER_FORMAT) + "%";
                    }

                    // FIELD_TYPE_WEATHER.
                    if (fieldType == FIELD_TYPE_WEATHER) {
                        weatherValue = weather["temp"]; // Celcius.
                        value = weatherValue.format(INTEGER_FORMAT) + "°C";
                    }
                    // Awaiting response.
                } else if (
                    App.Storage.getValue("PendingWebRequests") != null &&
                    App.Storage.getValue("PendingWebRequests")[
                        "OpenWeatherMapCurrent"
                    ]
                ) {
                    value = "%";
                }
                break;
            case FIELD_TYPE_RECOVERY_TIME:
                // value = gField13Val;
                break;
            case FIELD_TYPE_THERMOMETER:
                // value = gField14Val;
                break;
            default:
                value = "0";
                break;
        }
        if (value == null) {
            value = "0";
        }
        return value.toString();
    }

    function drawField(dc, fieldType, value, index) {
        var iconWidth = dc.getTextWidthInPixels(
            fieldType.toString(),
            _fMetricsIcon
        );
        dc.setColor(gIconColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            locX + iconWidth / 2,
            gHeight / 2 + _hMetricsFont * index,
            _fMetricsIcon,
            fieldType,
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
