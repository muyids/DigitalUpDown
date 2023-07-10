using Toybox.Background as Bg;
using Toybox.System as Sys;
using Toybox.Communications as Comms;
using Toybox.Application as App;
using Toybox.Application.Properties as Prop;

(:background)
class BackgroundService extends Sys.ServiceDelegate {
    (:background_method)
    function initialize() {
        Sys.ServiceDelegate.initialize();
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

    // Read pending web requests, and call appropriate web request function.
    // This function determines priority of web requests, if multiple are pending.
    // Pending web request flag will be cleared only once the background data has been successfully received.
    (:background_method)
    function onTemporalEvent() {
        Sys.println(getLogHeader() + " onTemporalEvent");
        var pendingWebRequests =
            Application.Storage.getValue("PendingWebRequests");
        if (pendingWebRequests != null) {
            Sys.println(
                getLogHeader() + "Pending web requests: " + pendingWebRequests
            );
            // Weather.
            if (pendingWebRequests["OpenWeatherMapCurrent"] != null) {
                var apiKey = Prop.getValue("OpenWeatherMapApiKey");

                makeWebRequest(
                    "https://api.openweathermap.org/data/2.5/weather",
                    {
                        "lat" => Application.Storage.getValue(
                            "LastLocationLat"
                        ),
                        "lon" => Application.Storage.getValue(
                            "LastLocationLng"
                        ),
                        "appid" => apiKey != null && apiKey.length() > 0
                            ? apiKey
                            : "null",
                    },
                    method(:onReceiveOpenWeatherMapCurrent)
                );
            }
        } else {
            Sys.println(
                getLogHeader() +
                    "onTemporalEvent() called with no pending web requests!"
            );
        }
    }

    // Sample invalid API key:
    /*
	{
		"cod":401,
		"message": "Invalid API key. Please see http://openweathermap.org/faq#error401 for more info."
	}
	*/

    // Sample current weather:
    /*
    {
        "coord": {
            "lon": 116.24,
            "lat": 39.54
        },
        "weather": [
            {
                "id": 803,
                "main": "Clouds",
                "description": "broken clouds",
                "icon": "04d"
            }
        ],
        "base": "stations",
        "main": {
            "temp": 308.86,
            "feels_like": 306.87,
            "temp_min": 308.86,
            "temp_max": 308.86,
            "pressure": 993,
            "humidity": 19,
            "sea_level": 993,
            "grnd_level": 989
        },
        "visibility": 10000,
        "wind": {
            "speed": 3.19,
            "deg": 6,
            "gust": 3.78
        },
        "clouds": {
            "all": 60
        },
        "dt": 1688696855,
        "sys": {
            "country": "CN",
            "sunrise": 1688676843,
            "sunset": 1688730314
        },
        "timezone": 28800,
        "id": 1807544,
        "name": "Daxing",
        "cod": 200
    }
	*/
    (:background_method)
    function onReceiveOpenWeatherMapCurrent(responseCode, data) {
        var result;

        // Useful data only available if result was successful.
        // Filter and flatten data response for data that we actually need.
        // Reduces runtime memory spike in main app.
        if (responseCode == 200) {
            result = {
                "cod" => data["cod"],
                "lat" => data["coord"]["lat"],
                "lon" => data["coord"]["lon"],
                "dt" => data["dt"],
                "temp" => data["main"]["temp"],
                "humidity" => data["main"]["humidity"],
                "icon" => data["weather"][0]["icon"],
                "sunrise" => data["sys"]["sunrise"],
                "sunset" => data["sys"]["sunset"],
            };

            // HTTP error: do not save.
        } else {
            result = {
                "httpError" => responseCode,
            };
        }
        Sys.println(
            getLogHeader() + "onReceiveOpenWeatherMapCurrent: " + result
        );
        Bg.exit({
            "OpenWeatherMapCurrent" => result,
        });
    }

    (:background_method)
    function makeWebRequest(url, params, callback) {
        var options = {
            :method => Comms.HTTP_REQUEST_METHOD_GET,
            :headers => {
                "Content-Type"
                =>
                Communications.REQUEST_CONTENT_TYPE_URL_ENCODED,
            },
            :responseType => Comms.HTTP_RESPONSE_CONTENT_TYPE_JSON,
        };

        Comms.makeWebRequest(url, params, options, callback);
    }
}
