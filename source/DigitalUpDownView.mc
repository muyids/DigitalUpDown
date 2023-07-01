import Toybox.Graphics;
import Toybox.Lang;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
import Toybox.Time.Gregorian;
import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Application;
using Toybox.Application.Properties as Prop;

var gBackgroundColour = Graphics.COLOR_BLACK;
var gFontColor = Graphics.COLOR_WHITE;
var gIconColor = Graphics.COLOR_RED;

var gThemeColour;
class DigitalUpDownView extends Ui.WatchFace {
  // Cache references to drawables immediately after layout, to avoid expensive
  // findDrawableById() calls in onUpdate();
  private var mDrawables = {};

  // fonts
  private var _fHourMinute, _fDate, _fMetricsIcon, _fMetricsFont;
  // font heights
  private var _hHourMinute, _hDate, _hMetricsIcon, _hMetricsFont;
  // block widths
  private var _wRightBlock, _wLeftBlock, _wCenterBlock, _wBottomBlock;

  private var _wPen = 5;

  public function initialize() {
    WatchFace.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    setLayout(Rez.Layouts.WatchFace(dc));
    // _fHourMinute = Graphics.FONT_NUMBER_THAI_HOT || Ui.loadResource($.Rez.Fonts.DyAgency);
    _fHourMinute = Ui.loadResource($.Rez.Fonts.Freshman);
    _fDate = Graphics.FONT_TINY;
    _fMetricsIcon = Ui.loadResource($.Rez.Fonts.MetricsIcon);
    _fMetricsFont = Ui.loadResource($.Rez.Fonts.MetricsFont);

    // Cache references to drawables immediately after layout, to avoid expensive
    _hHourMinute = dc.getFontHeight(_fHourMinute);
    _hDate = dc.getFontHeight(_fDate);
    _hMetricsIcon = dc.getFontHeight(_fMetricsIcon);
    _hMetricsFont = dc.getFontHeight(_fMetricsFont);

  }

  // Called when this View is brought to the foreground. Restore
  // the state of this View and prepare it to be shown. This includes
  // loading resources into memory.
  function onShow() as Void {}

  function getIntProperty(key, defaultValue) {
    var value = Prop.getValue(key);
    if (value == null) {
      value = defaultValue;
    } else if (!(value instanceof Number)) {
      value = value.toNumber();
    }
    return value;
  }

  public function onSettingsChanged() as Void {
    updateThemeColours();
  }

  function updateThemeColours() {
    var theme = getIntProperty("Theme", 0);
    // Theme-specific colours.
    gFontColor = [
      Graphics.COLOR_BLACK, // THEME_DARK_WHITE
      Graphics.COLOR_WHITE, // THEME_WHITE_DARK
      Graphics.COLOR_BLUE, // THEME_BLUE_DARK
      Graphics.COLOR_PINK, // THEME_PINK_DARK
      Graphics.COLOR_GREEN, // THEME_GREEN_DARK
      Graphics.COLOR_DK_GRAY, // THEME_MONO_LIGHT
      0x55aaff, // THEME_CORNFLOWER_BLUE_DARK
      0xffffaa, // THEME_LEMON_CREAM_DARK
      Graphics.COLOR_ORANGE, // THEME_DAYGLO_ORANGE_DARK
      Graphics.COLOR_RED, // THEME_RED_DARK
      Graphics.COLOR_WHITE, // THEME_MONO_DARK
      Graphics.COLOR_DK_BLUE, // THEME_BLUE_LIGHT
      Graphics.COLOR_DK_GREEN, // THEME_GREEN_LIGHT
      Graphics.COLOR_DK_RED, // THEME_RED_LIGHT
      0xffff00, // THEME_VIVID_YELLOW_DARK
      Graphics.COLOR_ORANGE, // THEME_DAYGLO_ORANGE_LIGHT
      Graphics.COLOR_YELLOW, // THEME_CORN_YELLOW_DARK
    ][theme];

    gIconColor = [
      Graphics.COLOR_BLUE, // THEME_DARK_WHITE
      Graphics.COLOR_RED, // THEME_WHITE_DARK
      Graphics.COLOR_RED, // THEME_BLUE_DARK
      Graphics.COLOR_RED, // THEME_PINK_DARK
      Graphics.COLOR_RED, // THEME_GREEN_DARK
      Graphics.COLOR_RED, // THEME_MONO_LIGHT
      Graphics.COLOR_RED, // THEME_CORNFLOWER_BLUE_DARK
      Graphics.COLOR_RED, // THEME_LEMON_CREAM_DARK
      Graphics.COLOR_RED, // THEME_DAYGLO_ORANGE_DARK
      Graphics.COLOR_RED, // THEME_RED_DARK
      Graphics.COLOR_RED, // THEME_MONO_DARK
      Graphics.COLOR_RED, // THEME_BLUE_LIGHT
      Graphics.COLOR_RED, // THEME_GREEN_LIGHT
      Graphics.COLOR_RED, // THEME_RED_LIGHT
      Graphics.COLOR_RED, // THEME_VIVID_YELLOW_DARK
      Graphics.COLOR_RED, // THEME_DAYGLO_ORANGE_LIGHT
      Graphics.COLOR_RED, // THEME_CORN_YELLOW_DARK
    ][theme];

    // Light/dark-specific colours.
    var lightFlags = [
      true, // THEME_BLUE_DARK
      false, // THEME_PINK_DARK
      false, // THEME_BLUE_DARK
      false, // THEME_PINK_DARK
      false, // THEME_GREEN_DARK
      true, // THEME_MONO_LIGHT
      false, // THEME_CORNFLOWER_BLUE_DARK
      false, // THEME_LEMON_CREAM_DARK
      false, // THEME_DAYGLO_ORANGE_DARK
      false, // THEME_RED_DARK
      false, // THEME_MONO_DARK
      true, // THEME_BLUE_LIGHT
      true, // THEME_GREEN_LIGHT
      true, // THEME_RED_LIGHT
      false, // THEME_VIVID_YELLOW_DARK
      true, // THEME_DAYGLO_ORANGE_LIGHT
      false, // THEME_CORN_YELLOW_DARK
    ];

    if (lightFlags[theme]) {
      gBackgroundColour = Graphics.COLOR_WHITE;
    } else {
      gBackgroundColour = Graphics.COLOR_BLACK;
    }
  }

  // Update the view
  function onUpdate(dc as Dc) as Void {
    var activityMonitor = ActivityMonitor.getInfo();

    dc.clearClip();
    dc.setColor(Graphics.COLOR_BLACK, gBackgroundColour);
    dc.clear();
    dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    var largeFontHeight = dc.getFontHeight(_fHourMinute);
    var smallFontHeight = dc.getFontHeight(_fMetricsFont);

    var nowTime = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
   
    var width = dc.getWidth();
    var height = dc.getHeight();
    // Fill the screen with a black rectangle
    dc.setColor(Graphics.COLOR_BLACK, gBackgroundColour);

    // Draw arc for hour
    dc.setColor(gIconColor, Graphics.COLOR_TRANSPARENT);
    dc.setPenWidth(_wPen);
    dc.drawArc(
      width / 2,
      width / 2,
      width / 2 - _wPen,
      Graphics.ARC_CLOCKWISE,
      240,
      70
    );

    // Draw the Time Hour&Minute String
    var hourStr =
      nowTime.hour < 10
        ? "0" + nowTime.hour.toString()
        : nowTime.hour.toString();
    var minuteStr =
      nowTime.min < 10 ? "0" + nowTime.min.toString() : nowTime.min.toString();

    var hourStrWidth = dc.getTextWidthInPixels(hourStr, _fHourMinute);
    var minuteStrWidth = dc.getTextWidthInPixels(minuteStr, _fHourMinute);
    _wCenterBlock = hourStrWidth > minuteStrWidth ? hourStrWidth : minuteStrWidth;
    dc.drawText(
      width / 2,
      height / 2 - largeFontHeight,
      _fHourMinute,
      hourStr,
      Graphics.TEXT_JUSTIFY_CENTER
    );

    dc.setColor(gFontColor, Graphics.COLOR_TRANSPARENT);

    dc.drawText(
      width / 2,
      height / 2,
      _fHourMinute,
      minuteStr,
      Graphics.TEXT_JUSTIFY_CENTER
    );
    var dateString = Lang.format("$1$\n$3$$2$日", [
      nowTime.day_of_week,
      nowTime.day,
      nowTime.month,
    ]);
   

    // Draw Date String
    var leftPadding = 4;
    _wLeftBlock = dc.getTextWidthInPixels(
      dateString,
      _fDate
    );
    _hDate = dc.getFontHeight(_fDate);
    var leftBlockCenterX = (leftPadding + _wPen + width / 2 - _wCenterBlock / 2) / 2;
    dc.drawText(
      leftBlockCenterX,
      height / 2 - _hDate,
      _fDate,
      dateString,
      Graphics.TEXT_JUSTIFY_CENTER
    );


    // Draw Metrics
    // include: calorie, steps, heartbeat in the right of the screen
    var rightXBase = width / 2 + _wCenterBlock / 2 + 5;

    var field1Icon = "0",
      field1Val = "435",
      field2Icon = "1",
      field2Val = "10532",
      field3Icon = "2",
      field3Val = "7";
    dc.setColor(gIconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      rightXBase + dc.getTextWidthInPixels(field1Icon, _fMetricsIcon),
      height / 2 - _hMetricsFont,
      _fMetricsIcon,
      field1Icon,
      Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.drawText(
      rightXBase + dc.getTextWidthInPixels(field2Icon, _fMetricsIcon),
      height / 2,
      _fMetricsIcon,
      field2Icon,
      Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.drawText(
      rightXBase + dc.getTextWidthInPixels(field3Icon, _fMetricsIcon),
      height / 2 + _hMetricsFont,
      _fMetricsIcon,
      field3Icon,
      Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.setColor(gFontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      rightXBase +
        dc.getTextWidthInPixels(field1Icon, _fMetricsIcon) +
        dc.getTextWidthInPixels(field1Val, _fMetricsFont),
      height / 2 - _hMetricsFont,
      _fMetricsFont,
      field1Val,
      Graphics.TEXT_JUSTIFY_VCENTER
    );
    dc.drawText(
      rightXBase +
        dc.getTextWidthInPixels(field1Icon, _fMetricsIcon) +
        dc.getTextWidthInPixels(field2Val, _fMetricsFont),
      height / 2,
      _fMetricsFont,
      field2Val,
      Graphics.TEXT_JUSTIFY_VCENTER
    );

    dc.drawText(
      rightXBase +
        dc.getTextWidthInPixels(field1Icon, _fMetricsIcon) +
        dc.getTextWidthInPixels(field3Val, _fMetricsFont),
      height / 2 + _hMetricsFont,
      _fMetricsFont,
      field3Val,
      Graphics.TEXT_JUSTIFY_VCENTER
    );

    // Draw the battery level in the bottom of the screen
    var batteryPaddingBottom = 0, batteryInterval = 3;
    var battery = Lang.format("$1$%", [Sys.getSystemStats().battery.toLong()]);
    var batteryIconWidth = dc.getTextWidthInPixels("3", _fMetricsIcon);
    var batteryMeterWidth = dc.getTextWidthInPixels(battery, _fMetricsFont);
    _wBottomBlock = batteryIconWidth + batteryMeterWidth + batteryInterval;
    dc.setColor(gIconColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
      width / 2 - _wBottomBlock / 2 + batteryIconWidth - batteryInterval / 2,
      height - batteryPaddingBottom - _hMetricsIcon/ 2 - _hMetricsFont / 2 + _hMetricsIcon / 2,
      _fMetricsIcon,
      "3",
      Graphics.TEXT_JUSTIFY_VCENTER
    );
 
    dc.setColor(gFontColor, Graphics.COLOR_TRANSPARENT);
    dc.drawText(
       width / 2 + batteryIconWidth / 2+ batteryMeterWidth / 2 + batteryInterval / 2,
      height - batteryPaddingBottom - _hMetricsFont / 2,
      _fMetricsFont,
      battery,
      Graphics.TEXT_JUSTIFY_VCENTER
    );
    
  }

  // Called when this View is removed from the screen. Save the
  // state of this View here. This includes freeing resources from memory.
  function onHide() as Void {}

  // The user has just looked at their watch. Timers and animations may be
  // started here.
  function onExitSleep() as Void {}

  // Terminate any active timers and prepare for slow updates.
  function onEnterSleep() as Void {}
}
