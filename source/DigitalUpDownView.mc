import Toybox.Graphics;
import Toybox.Lang;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
import Toybox.Time.Gregorian;
import Toybox.Activity;
using Toybox.ActivityMonitor as ActivityMonitor;
import Toybox.Application;
using Toybox.Application.Properties as Prop;

var gWidth, gHeight, _wPen = 5;
var gBackgroundColour = Graphics.COLOR_BLACK;
var gFontColor = Graphics.COLOR_WHITE;
var gIconColor = Graphics.COLOR_RED;
var gThemeColour;
var gField1Type = "1", gField2Type = "5", gField3Type = "6";

// fonts
var _fHourMinute, _fDate, _fMetricsIcon, _fMetricsFont;
// font heights
var _hHourMinute, _hDate, _hMetricsIcon, _hMetricsFont;
// block widths
var _wRightBlock, _wLeftBlock, _wCenterBlock, _wBottomBlock;

class DigitalUpDownView extends Ui.WatchFace {
  // Cache references to drawables immediately after layout, to avoid expensive
  // findDrawableById() calls in onUpdate();
  private var mDrawables = {};

  public function initialize() {
    WatchFace.initialize();
  }

  // Load your resources here
  function onLayout(dc as Dc) as Void {
    gWidth = dc.getWidth();
    gHeight = dc.getHeight();
    
    _fHourMinute = Ui.loadResource($.Rez.Fonts.Freshman);
    _fDate = Graphics.FONT_TINY;
    _fMetricsIcon = Ui.loadResource($.Rez.Fonts.IconFont);
    _fMetricsFont = Ui.loadResource($.Rez.Fonts.MetricsFont);

    _hHourMinute = dc.getFontHeight(_fHourMinute);
    _hDate = dc.getFontHeight(_fDate);
    _hMetricsIcon = dc.getFontHeight(_fMetricsIcon);
    _hMetricsFont = dc.getFontHeight(_fMetricsFont);

    setLayout(Rez.Layouts.WatchFace(dc));

    // Cache references to drawables immediately after layout, to avoid expensive
    cacheDrawables();
  }

  function cacheDrawables() {
    mDrawables[:CenterArea] = View.findDrawableById("CenterArea");
    mDrawables[:RightArea] = View.findDrawableById("RightArea");
    mDrawables[:LeftArea] = View.findDrawableById("LeftArea");
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

    updateMetrics();
  }

  function updateMetrics() {
    gField1Type = getIntProperty("Field1", 0);
    gField2Type = getIntProperty("Field2", 5);
    gField3Type = getIntProperty("Field3", 6);

    Sys.println("Field1: " + gField1Type);
    Sys.println("Field2: " + gField2Type);
    Sys.println("Field3: " + gField3Type);
  }

  function updateThemeColours() {
    var theme = getIntProperty("Theme", 1);
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
		// Clear any partial update clipping.
		if (dc has :clearClip) {
			dc.clearClip();
		}

    // dc.setColor(Graphics.COLOR_BLACK, gBackgroundColour);
    // dc.clear();
    // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

    // Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);
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
