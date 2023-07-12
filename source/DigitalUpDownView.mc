using Toybox.Graphics as Gfx;
import Toybox.Lang;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
import Toybox.Time.Gregorian;
import Toybox.Activity;
using Toybox.ActivityMonitor as ActivityMonitor;
using Toybox.Application as App;
using Toybox.Application.Properties as Prop;

var gWidth,
    gHeight,
    _wPen = 5;
var gBackgroundColour = Gfx.COLOR_BLACK;
var gFontColor = Gfx.COLOR_WHITE;
var gIconColor = Gfx.COLOR_RED;
var gThemeColour;

const INTEGER_FORMAT = "%d";

var _fHourMinute, _fDate, _fMetricsIcon, _fMetricsFont;
var _hHourMinute, _hDate, _hMetricsIcon, _hMetricsFont;
var _wRightBlock, _wLeftBlock, _wCenterBlock, _wBottomBlock;

class DigitalUpDownView extends Ui.WatchFace {
    // Cache references to drawables immediately after layout, to avoid expensive
    // findDrawableById() calls in onUpdate();
    private var mDrawables = {};

    public function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Gfx.Dc) as Void {
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

        // Cache references to drawables immediately after layout, to avoid
        // expensive
        cacheDrawables();
    }

    function cacheDrawables() {
        mDrawables[:Background] = View.findDrawableById("Background");
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

    public function onSettingsChanged() as Void {
        Sys.println(getLogHeader() + "View.onSettingsChanged");

        updateThemeColours();

        updateMetrics();

        if (DigitalUpDownApp has :checkPendingWebRequests) {
            App.getApp().checkPendingWebRequests();
        }
    }

    function updateMetrics() {
        gField1Type = getIntProperty("Field1", 0);
        gField2Type = getIntProperty("Field2", 5);
        gField3Type = getIntProperty("Field3", 6);
    }

    function updateThemeColours() {
        var theme = getIntProperty("Theme", 0);
        // Theme-specific colours.
        gIconColor = [
            Graphics.COLOR_RED, // THEME_RED_WHITE
            Graphics.COLOR_BLUE, // THEME_BLUE_WHITE
            Graphics.COLOR_RED, // THEME_RED_PINK
            Graphics.COLOR_BLUE, // THEME_BLUE_PINK
            Graphics.COLOR_RED, // THEME_RED_GREEN
            Graphics.COLOR_BLUE, // THEME_BLUE_GREEN
            Graphics.COLOR_RED, // THEME_RED_YELLOW
            Graphics.COLOR_BLUE, // THEME_BLUE_YELLOW
            // Graphics.COLOR_RED,  // THEME_DAYGLO_ORANGE_DARK
            // Graphics.COLOR_RED,  // THEME_RED_DARK
            // Graphics.COLOR_RED,  // THEME_MONO_DARK
            // Graphics.COLOR_RED,  // THEME_BLUE_LIGHT
            // Graphics.COLOR_RED,  // THEME_GREEN_LIGHT
            // Graphics.COLOR_RED,  // THEME_RED_LIGHT
            // Graphics.COLOR_RED,  // THEME_VIVID_YELLOW_DARK
            // Graphics.COLOR_RED,  // THEME_DAYGLO_ORANGE_LIGHT
            // Graphics.COLOR_RED,  // THEME_CORN_YELLOW_DARK
        ][theme];
        gFontColor = [
            Graphics.COLOR_WHITE,
            Graphics.COLOR_WHITE,
            Graphics.COLOR_PINK,
            Graphics.COLOR_PINK,
            Graphics.COLOR_GREEN,
            Graphics.COLOR_GREEN,
            Graphics.COLOR_YELLOW,
            Graphics.COLOR_YELLOW,

            // Graphics.COLOR_DK_GRAY,   // THEME_MONO_LIGHT
            // 0x55aaff,                 // THEME_CORNFLOWER_BLUE_DARK
            // 0xffffaa,                 // THEME_LEMON_CREAM_DARK
            // Graphics.COLOR_ORANGE,    // THEME_DAYGLO_ORANGE_DARK
            // Graphics.COLOR_RED,       // THEME_RED_DARK
            // Graphics.COLOR_WHITE,     // THEME_MONO_DARK
            // Graphics.COLOR_DK_BLUE,   // THEME_BLUE_LIGHT
            // Graphics.COLOR_DK_GREEN,  // THEME_GREEN_LIGHT
            // Graphics.COLOR_DK_RED,    // THEME_RED_LIGHT
            // 0xffff00,                 // THEME_VIVID_YELLOW_DARK
            // Graphics.COLOR_ORANGE,    // THEME_DAYGLO_ORANGE_LIGHT
        ][theme];

        // Light/dark-specific colours.
        var lightFlags = [
            false,
            false,
            false,
            false,
            false,
            false,
            false,
            false,
        ];

        if (lightFlags[theme]) {
            gBackgroundColour = Graphics.COLOR_WHITE;
        } else {
            gBackgroundColour = Graphics.COLOR_BLACK;
        }
    }

    // Update the view
    function onUpdate(dc as Gfx.Dc) as Void {
        // Clear any partial update clipping.
        if (dc has :clearClip) {
            dc.clearClip();
        }
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from memory.
    function onHide() as Void {}

    // The user has just looked at their watch. Timers and animations may be
    // started here.
    function onExitSleep() as Void {
        // Rather than checking the need for background requests on a timer, or on
        // the hour, easier just to check when exiting sleep.
        if (DigitalUpDownApp has :checkPendingWebRequests) {
            App.getApp().checkPendingWebRequests();
        }
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {}
}
