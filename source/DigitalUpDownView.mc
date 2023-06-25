import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
import Toybox.Activity;
import Toybox.ActivityMonitor;

class DigitalUpDownView extends WatchUi.WatchFace {
    private var _width;
    private var _height;
    private var _font_large;
    private var _font;
    private var _heartBitmap as BitmapResource?;
    private var _stepsBitmap as BitmapResource?;
    private var _calorieBitmap as BitmapResource?;

    private var _batteryLowBitmap as BitmapResource?;
    private var _batteryMidBitmap as BitmapResource?;

    public function initialize() {
        WatchFace.initialize();

        var settings = System.getDeviceSettings();

        System.println("screenWidth: " + settings.screenWidth + "; screenHeight: " + settings.screenHeight);
    
        _width = settings.screenWidth;
        _height = settings.screenHeight;
      
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        // Load the custom font we use for drawing the 3, 6, 9, and 12 on the watchface.
        // _font = WatchUi.loadResource($.Rez.Fonts.id_font_black_diamond) as FontResource;
        _font = Graphics.FONT_TINY;
        _font_large = Graphics.FONT_NUMBER_THAI_HOT;

        _heartBitmap = WatchUi.loadResource($.Rez.Drawables.HeartRateIcon) as BitmapResource;
        _calorieBitmap = WatchUi.loadResource($.Rez.Drawables.CalorieIcon) as BitmapResource;
        _stepsBitmap = WatchUi.loadResource($.Rez.Drawables.StepsIcon) as BitmapResource;
        _batteryLowBitmap = WatchUi.loadResource($.Rez.Drawables.BatteryLowIcon) as BitmapResource;
        _batteryMidBitmap = WatchUi.loadResource($.Rez.Drawables.BatteryMidIcon) as BitmapResource;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {

    }
    

    // Update the view
    function onUpdate(dc as Dc) as Void {
        var profile = UserProfile.getProfile();
        var activityMonitor = ActivityMonitor.getInfo();

        dc.clearClip();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        
        var largeFontHeight = dc.getFontHeight(_font_large);
        var smallFontHeight = dc.getFontHeight(_font);

        var nowTime = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dateString = Lang.format(
            "$1$\n$3$$2$日",
            [
                nowTime.day_of_week,
                nowTime.day,
                nowTime.month,
            ]
        );
        var width = dc.getWidth();
        var height = dc.getHeight();
        // Fill the screen with a black rectangle
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);

        // var mySmiley = new Rez.Drawables.OutCricle();
        // mySmiley.draw( dc );

        // Draw arc for hour
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(5);
        dc.drawArc(109, 109, 107, Graphics.ARC_CLOCKWISE, 240, 70);

        // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 240, 239);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 238, 237);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 236, 235);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 234, 233);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 232, 231);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 230, 229);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 228, 227);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 226, 225);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 224, 223);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 222, 221);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 220, 219);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 218, 217);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 216, 215);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 214, 213);
        // dc.drawArc(110, 110, 105, Graphics.ARC_CLOCKWISE, 212, 211);

         // Fill the top right half of the screen with a grey triangle
        // dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        // dc.fillPolygon([[0, 0] as Array<Number>, [_width, 0] as Array<Number>, [_width, _height] as Array<Number>, [0, 0] as Array<Number>]  as Array< Array<Number> >);

 
        // Draw the Time Hour String
        var hourStr = nowTime.hour < 10 ? "0" + nowTime.hour.toString() : nowTime.hour.toString();
        var hourStrWidth = dc.getTextWidthInPixels(hourStr, _font_large);
        // dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        // dc.fillRectangle(((width-hourStrWidth)/2), (height/2 - largeFontHeight),hourStrWidth, largeFontHeight);
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width/2, (height/2 - largeFontHeight + 10), _font_large, hourStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Draw the Time Minute String
        // dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        // dc.fillRectangle(((width-hourStrWidth)/2), (height/2),hourStrWidth, largeFontHeight);
        var minuteStr = nowTime.min < 10 ? "0" + nowTime.min.toString() : nowTime.min.toString();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width/2, _height/2 - 10, _font_large, minuteStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Draw the date string in the left-center of the screen
        var dateStrWidth = dc.getTextWidthInPixels(dateString, _font);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width / 2 - hourStrWidth / 2 - dateStrWidth / 2, _height/2, _font, dateString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Draw the calorie, steps, heartbeat in the right of the screen
        var rightXBase = width / 2 + hourStrWidth / 2 + 3;
        var calStr = activityMonitor.calories.toString();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawBitmap(rightXBase,  height / 2 - smallFontHeight, _calorieBitmap);
        dc.drawText(rightXBase + _heartBitmap.getWidth() + dc.getTextWidthInPixels(calStr, _font) / 2, height / 2 - smallFontHeight -7, _font, calStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Draw the steps in the middle of the screen
        var stepsStr = activityMonitor.steps.toString();
        dc.drawBitmap(rightXBase,  height / 2, _stepsBitmap);
        dc.drawText(rightXBase+ _heartBitmap.getWidth() + dc.getTextWidthInPixels(stepsStr, _font) / 2, _height / 2 -7 , _font, stepsStr, Graphics.TEXT_JUSTIFY_CENTER );

        // Draw the heart rate in the bottom of the screen
        var heartStr = "--";
        // var restingHeartRate = Activity.Info.currentHeartRate;
        var restingHeartRate = Activity.getActivityInfo().currentHeartRate;
        if (restingHeartRate != null) {
            heartStr = restingHeartRate.toString();
        } 

        dc.drawBitmap(rightXBase,  height / 2 + smallFontHeight, _heartBitmap);
        dc.drawText(rightXBase + _heartBitmap.getWidth() + dc.getTextWidthInPixels(heartStr, _font) / 2, height / 2 + smallFontHeight -7 , _font, heartStr, Graphics.TEXT_JUSTIFY_CENTER);

        // Draw the battery level in the bottom of the screen
        var batteryLevel = System.getSystemStats().battery.toLong();
        var batteryLevelStr = Lang.format("$1$%", [batteryLevel]);
        var batteryLevelWidth = dc.getTextWidthInPixels(batteryLevelStr, _font);
        if (batteryLevel < 20) {
            dc.drawBitmap(width / 2 - batteryLevelWidth, height / 2 + largeFontHeight + ( smallFontHeight- _batteryLowBitmap.getWidth())/ 2, _batteryLowBitmap);
        } else {
            dc.drawBitmap(width / 2 - batteryLevelWidth, height / 2 + largeFontHeight+ ( smallFontHeight- _batteryLowBitmap.getWidth())/ 2, _batteryMidBitmap);
        }
        dc.drawText(width/2+ _batteryLowBitmap.getWidth() / 2, height / 2 + largeFontHeight, _font, batteryLevelStr, Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

}
