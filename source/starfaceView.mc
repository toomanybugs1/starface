import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.ActivityMonitor;
import Toybox.Activity;
import Toybox.Math;

class starfaceView extends WatchUi.WatchFace {

    private var fontLarge;
    private var fontSmall;
    private var backgroundImg;
    private var faceDisplayImg;
    private var handImg;
    private var notifImg;

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        fontLarge = Application.loadResource(Rez.Fonts.StardewLarge);
        fontSmall = Application.loadResource(Rez.Fonts.StardewSmall);
        backgroundImg = Application.loadResource(Rez.Drawables.Background);
        faceDisplayImg = Application.loadResource(Rez.Drawables.Display);
        notifImg = Application.loadResource(Rez.Drawables.Notification);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);

        // Get and show the current time
        //var clockTime = System.getClockTime();
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        
        drawBackground(dc);
        drawClockFace(dc);
        drawBattery(dc);

        // Call the parent onUpdate function to redraw the layout
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        drawTime(dc, today);
        drawDate(dc, today);
        drawSteps(dc);
        drawHeartRate(dc);
        drawHand(dc, today);
        drawNotif(dc);
    }

    function drawTime(dc as Dc, today) {
        var timeString = getFormattedTime(today.hour, today.min, System.getDeviceSettings().is24Hour);
        dc.drawText(
            158, 
            140, 
            fontLarge,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawDate(dc as Dc, today) {
        var dayString = Lang.format("$1$. $2$", [ today.day_of_week, today.day.format("%02d") ]);
        dc.drawText(
            158, 
            73, 
            fontLarge,
            dayString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawHeartRate(dc as Dc) {
        var heartRate = 0;
        
        var info = Activity.getActivityInfo();
        if (info != null) {
            heartRate = info.currentHeartRate;
        } else {
            var latestHeartRateSample = ActivityMonitor.getHeartRateHistory(1, true).next();
            if (latestHeartRateSample != null) {
                heartRate = latestHeartRateSample.heartRate;
            }
        }
        
        dc.drawText(
            192, 
            105, 
            fontSmall,
            (heartRate == 0 || heartRate == null) ? "--" : heartRate.format("%d"),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawBackground(dc as Dc) {
        dc.drawBitmap(
            0,
            0,
            backgroundImg
        );
    }

    function drawNotif(dc as Dc) {
        if (ActivityMonitor.getInfo().moveBarLevel != null && ActivityMonitor.getInfo().moveBarLevel > ActivityMonitor.MOVE_BAR_LEVEL_MIN) {
                dc.drawBitmap(
                0,
                0,
                notifImg
            );
        }
    }

    function drawClockFace(dc as Dc) {
        dc.drawBitmap(
            0,
            0,
            faceDisplayImg
        );
    }

    function drawSteps(dc as Dc) {
        var stepString = "-";

        if (ActivityMonitor.getInfo().steps != null) {
            stepString = Lang.format("$1$", [ ActivityMonitor.getInfo().steps ]);
        }
        
        dc.drawText(
            202, 
            200, 
            fontLarge,
            stepString,
            Graphics.TEXT_JUSTIFY_RIGHT | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function drawBattery(dc) {
        var batteryPercent = System.getSystemStats().battery / 100;
        var color;

        if (batteryPercent > 0.7) {
            color = Graphics.COLOR_DK_GREEN;
        }
        else if (batteryPercent < 0.25) {
            color = Graphics.COLOR_DK_RED;
        }
        else {
            color = Graphics.COLOR_YELLOW;
        }

        // these are the coords/dimensions when we have full battery
        var topLeftX = 71;
        var topLeftY = 188;
        var width = 22;
        var height = 25;

        var adjustedHeight = Math.ceil(batteryPercent * height);

        dc.setColor(color, Graphics.COLOR_BLACK);
        dc.fillRectangle(topLeftX, topLeftY + (height - adjustedHeight), width, adjustedHeight);
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

    hidden function getFormattedTime(hour, min, is24hour)
    {
        if (is24hour) {
        return Lang.format("$1$:$2$", [ hour.format("%02d"), min.format("%02d") ]);
        }
        else {
            var ampm = (hour < 12) ? "AM" : "PM"; // should use resource strings
            hour = (hour + 11) % 12 + 1;

            return Lang.format("$1$:$2$ $3$", [ hour, min.format("%02d"), ampm ]);
        }
    }

    // don't make fun of me for this, rotating bitmaps is a nightmare and I only have a weekend to do this
    function drawHand(dc as Dc, today) {
        switch(today.hour) {
            case 0:
            case 1:
                handImg = Application.loadResource(Rez.Drawables.h0);
                break;
            case 2:
            case 3:
            case 4:
                handImg = Application.loadResource(Rez.Drawables.h1);
                break;
            case 5:
            case 6:
                handImg = Application.loadResource(Rez.Drawables.h3);
                break;
            case 7:
            case 8:
                handImg = Application.loadResource(Rez.Drawables.h4);
                break;
            case 9:
            case 10:
            case 11:
                handImg = Application.loadResource(Rez.Drawables.h5);
                break;
            case 12:
            case 13:
                handImg = Application.loadResource(Rez.Drawables.h6);
                break;
            case 14:
            case 15:
            case 16:
                handImg = Application.loadResource(Rez.Drawables.h7);
                break;
            case 17:
            case 18:
                handImg = Application.loadResource(Rez.Drawables.h8);
                break;
            case 19:
            case 20:
                handImg = Application.loadResource(Rez.Drawables.h9);
                break;
            case 21:
            case 22:
                handImg = Application.loadResource(Rez.Drawables.h10);
                break;
            case 23:
                handImg = Application.loadResource(Rez.Drawables.h11);
                break;
        }

        dc.drawBitmap(
            0,
            0,
            handImg
        );
    }
}
