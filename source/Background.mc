using Toybox.WatchUi as Ui;
using Toybox.Application as App;
using Toybox.Graphics as Gfx;

class Background extends Ui.Drawable {
    function initialize(params) {
        Drawable.initialize(params);
    }

    function draw(dc) {
        // Set the background color then call to clear the screen
        dc.setColor(Gfx.COLOR_TRANSPARENT, gBackgroundColour);
        dc.clear();

        // Draw arc
        dc.setColor(gIconColor, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(_wPen);
        dc.drawArc(
            gWidth / 2,
            gWidth / 2,
            gWidth / 2 - _wPen / 2,
            Graphics.ARC_CLOCKWISE,
            240,
            70
        );
    }
}
