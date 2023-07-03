using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

class LeftArea extends Ui.Drawable {
    function initialize(params) {
        Drawable.initialize(params);
    }

    function draw(dc) {
        var nowTime = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var deviceSettings = System.getDeviceSettings();

        var dateString = Lang.format("$1$\n$2$ $3$", [
            nowTime.day_of_week,
            nowTime.month,
            nowTime.day,
        ]);
        if (deviceSettings has :systemLanguage) {
            if (deviceSettings.systemLanguage == System.LANGUAGE_CHS) {
                dateString = Lang.format("$1$\n$2$$3$日", [
                    nowTime.day_of_week,
                    nowTime.month,
                    nowTime.day,
                ]);
            }
        }

        var leftPadding = 4;
        _wLeftBlock = dc.getTextWidthInPixels(dateString, _fDate);
        _hDate = dc.getFontHeight(_fDate);
        var leftBlockCenterX =
            (leftPadding + _wPen + gWidth / 2 - _wCenterBlock / 2) / 2;
        dc.setColor(gFontColor, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
            leftBlockCenterX,
            gHeight / 2 - _hDate,
            _fDate,
            dateString,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }
}
