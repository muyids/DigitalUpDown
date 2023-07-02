using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;

class BottomArea extends Ui.Drawable {
 private
  var locX;
 private
  var locY;
 private
  var width;
 private
  var height;

  function initialize(params) {
    Drawable.initialize(params);

    locX = params[:locX];
    locY = params[:locY];
    width = params[:width];
    height = params[:height];
  }

  function draw(dc) {
    // Draw the battery level in the bottom of the screen
    var batteryPaddingBottom = 0, batteryInterval = 3;
    var battery = Lang.format("$1$%", [Sys.getSystemStats().battery.toLong()]);
    var batteryIconWidth = dc.getTextWidthInPixels("3", _fMetricsIcon);
    var batteryMeterWidth = dc.getTextWidthInPixels(battery, _fMetricsFont);

    dc.setColor(gIconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(locX + batteryIconWidth / 2, locY + height / 2, _fMetricsIcon,
                "3",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

    dc.setColor(gFontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
        locX + batteryIconWidth + batteryMeterWidth / 2 + batteryInterval,
        locY + height / 2, _fMetricsFont, battery,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
  }
}
