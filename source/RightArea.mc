using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Activity as Activity;

class RightArea extends Ui.Drawable {
  private var locX, locY, width, height;
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
  var dict = {
    10 => "A",
    11 => "B",
    12 => "C",
    13 => "D",
    14 => "E",
    15 => "F",
    16 => "G",
    17 => "H",
    18 => "I",
    19 => "J",
    20 => "K",
    21 => "L",
    22 => "M",
    23 => "N",
  };

  function initialize(params) {
    Drawable.initialize(params);
    self.locX = params[:locX];
    self.locY = params[:locY];
    self.width = params[:width];
    self.height = params[:height];
  }

  function draw(dc) {
    // Draw Metrics
    if (dict.hasKey(gField1Type)) {
      gField1Type = dict.get(gField1Type);
    }
    if (dict.hasKey(gField2Type)) {
      gField2Type = dict.get(gField2Type);
    }
    if (dict.hasKey(gField3Type)) {
      gField3Type = dict.get(gField3Type);
    }
    drawField(dc, gField1Type, getFieldVal(gField1Type), -1);
    drawField(dc, gField2Type, getFieldVal(gField2Type), 0);
    drawField(dc, gField3Type, getFieldVal(gField3Type), 1);
  }

  function getFieldVal(fieldType) {
    var info = ActivityMonitor.getInfo();
    var activityInfo = Activity.getActivityInfo();
    var fieldVal = "0";
    switch (fieldType.toString()) {
      case "0":
        fieldVal = activityInfo.currentHeartRate;
        break;
      case "1":
        fieldVal = info.battery;
        break;
      case "2":
        fieldVal = info.battery;
        break;
      case "3":
        fieldVal = info.battery;
        break;
      case "4":
        fieldVal = info.battery;
        break;
      case "5":
        fieldVal = info.steps;
        break;
      case "6":
        fieldVal = info.floorsClimbed;
        break;
      case "7":
        fieldVal = info.calories;
        break;
      case "8":
        break;
      case "9":
        // fieldVal = gField9Val;
        break;
      case "A":
        fieldVal = info.activeMinutesWeek.total;
        break;
      case "B":
        fieldVal = info.distance / 100;
        break;
      case "C":
        // fieldVal = gField3Val;
        break;
      case "D":
        // fieldVal = gField4Val;
        break;
      case "E":
        // fieldVal = gField5Val;
        break;
      case "F":
        // fieldVal = gField6Val;
        break;
      case "G":
        // fieldVal = gField7Val;
        break;
      case "H":
        // fieldVal = gField8Val;
        break;
      case "I":
        // fieldVal = gField9Val;
        break;
      case "J":
        // fieldVal = gField10Val;
        break;
      case "K":
        // fieldVal = gField11Val;
        break;
      case "L":
        // fieldVal = gField12Val;
        break;
      case "M":
        // fieldVal = gField13Val;
        break;
      case "N":
        // fieldVal = gField14Val;
        break;
      default:
        fieldVal = "0";
        break;
    }
    if (fieldVal == null) {
      fieldVal = "0";
    }
    return fieldVal.toString();
  }

  function drawField(dc, fieldType, fieldVal, index) {
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
      locX + iconWidth + dc.getTextWidthInPixels(fieldVal, _fMetricsFont),
      gHeight / 2 + _hMetricsFont * index,
      _fMetricsFont,
      fieldVal,
       Graphics.TEXT_JUSTIFY_VCENTER
    );
  }
}
