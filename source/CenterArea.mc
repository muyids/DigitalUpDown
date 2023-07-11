using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

class CenterArea extends Ui.Drawable {
    
    function initialize(params) {
        Drawable.initialize(params);
    }

    function draw(dc) {
        // Draw the Time Hour&Minute String
        var nowTime = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var hourStr =
            nowTime.hour < 10
                ? "0" + nowTime.hour.toString()
                : nowTime.hour.toString();
        var minuteStr =
            nowTime.min < 10
                ? "0" + nowTime.min.toString()
                : nowTime.min.toString();

        var hourStrWidth = dc.getTextWidthInPixels(hourStr, _fHourMinute);
        var minuteStrWidth = dc.getTextWidthInPixels(minuteStr, _fHourMinute);

        _wCenterBlock =
            hourStrWidth > minuteStrWidth ? hourStrWidth : minuteStrWidth;

        dc.setColor(gIconColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gWidth / 2,
            gHeight / 2 - _hHourMinute,
            _fHourMinute,
            hourStr,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.setColor(gFontColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            gWidth / 2,
            gHeight / 2,
            _fHourMinute,
            minuteStr,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}
