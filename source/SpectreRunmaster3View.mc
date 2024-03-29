import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.Math;
import Toybox.Time;
using Toybox.SensorHistory as Sensor;
import Toybox.ActivityMonitor;
import Toybox.Application;


class SpectreRunmaster3View extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }
    
	private function generateHandCoordinates(centerPoint as Array<Number>, angle as Float, handLength as Number, tailLength as Number, startWidth as Number, endWidth as Number) as Array< Array<Float> > {
        // Map out the coordinates of the watch hand
        var coords = [[-(startWidth / 2), tailLength] as Array<Number>,
                      [-(endWidth / 2), -handLength] as Array<Number>,
                      [endWidth / 2, -handLength] as Array<Number>,
                      [startWidth / 2, tailLength] as Array<Number>] as Array< Array<Number> >;
        var result = new Array< Array<Float> >[4];
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i++) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
            var y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;

            result[i] = [centerPoint[0] + x, centerPoint[1] + y] as Array<Float>;
        }
        return result;
    }

    // Draws the clock tick marks around the outside edges of the screen.
    private function drawHashMarks(dc as Dc, count as Number, skip as Number, scale_to_fenix as Number) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        
        var outerRad = width / 2;
        var innerRad = outerRad - 25 * scale_to_fenix;
        
        for (var i = 1; i <= count; i += 1) {
	        if (i % skip != 0){
	            var angle = i * (Math.PI/count)*2;
	            var sY = outerRad + innerRad * Math.sin(angle);
	            var eY = outerRad + outerRad * Math.sin(angle);
	            var sX = outerRad + innerRad * Math.cos(angle);
	            var eX = outerRad + outerRad * Math.cos(angle);
	            dc.drawLine(sX, sY, eX, eY);
	            }
        }
    }

    private function drawMainNumbers(dc as Dc, scale_to_fenix as Number) as Void {
    	var width = dc.getWidth();
        var height = dc.getHeight();
        
        var outerRad = width / 2;
        var innerRad = outerRad - 25 * scale_to_fenix;
		var distfromside = 45 * scale_to_fenix;
		
		
		dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
		// FURTHER WORK REQUIRED: Use a thicker or different font for watches withn fancier displays like the Venu 2
		dc.drawText(width/2, width-distfromside, Graphics.FONT_NUMBER_MILD, 6, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(width-distfromside, width/2, Graphics.FONT_NUMBER_MILD, 3, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
		dc.drawText(distfromside, width/2, Graphics.FONT_NUMBER_MILD, 9, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

		
		var top_indicator = Application.getApp().Properties.getValue("top_numeric");
		switch (top_indicator){
			case 0:
				// Creating the pilot triangle at the top
				var triangle_width = 18 * scale_to_fenix;
				var triangle_height = 28 * scale_to_fenix;
				var triangle_spacer = -14 * scale_to_fenix;
				var triangle_eye_rad = 5 * scale_to_fenix;
				
				dc.fillPolygon([
					[width/2, distfromside + triangle_spacer],
					[width/2 - triangle_width, distfromside + triangle_spacer + triangle_height],
					[width/2 + triangle_width, distfromside + triangle_spacer + triangle_height]
					]);
					
			    dc.fillCircle(width/2 - triangle_eye_rad - 9*scale_to_fenix, distfromside + triangle_spacer + 3, triangle_eye_rad);
			    dc.fillCircle(width/2 + triangle_eye_rad + 9*scale_to_fenix, distfromside + triangle_spacer + 3, triangle_eye_rad);
				break;
			case 1:
				dc.drawText(width/2, distfromside, Graphics.FONT_NUMBER_MILD, 12, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
				break;
		}
		
    }

    private function drawMainTriangles(dc as Dc, count as Number, skipper as Number, thickness as Number, shortener as Number, scale_to_fenix as Number) as Void {
    	var width = dc.getWidth();
        var height = dc.getHeight();
        
        thickness = thickness * scale_to_fenix;
        shortener = shortener * scale_to_fenix;

        var outerRad = (width) / 2;
        var innerRad = outerRad - 20*scale_to_fenix + shortener;

        for (var i = 0; i < count; i += 1) {
        	if (skipper == 0 ||  i % skipper != 0){
	        	// s in on the inside 
	            var angle = i * (Math.PI/count)*2;
	            var sY = outerRad + innerRad * Math.sin(angle);
	            var sX = outerRad + innerRad * Math.cos(angle);
	
	            var eY_u = outerRad + (outerRad + 10*scale_to_fenix) * Math.sin(angle) + thickness * Math.cos(angle);
	            var eX_u = outerRad + (outerRad + 10*scale_to_fenix) * Math.cos(angle) + thickness * Math.sin(angle);
	            
	            var eY_l = outerRad + (outerRad + 10*scale_to_fenix) * Math.sin(angle) - thickness * Math.cos(angle);
	            var eX_l = outerRad + (outerRad + 10*scale_to_fenix) * Math.cos(angle) - thickness * Math.sin(angle);
	
	            dc.fillPolygon([[sY, sX],[eY_u, eX_u],[eY_l, eX_l]]);
            }
        }
    }


	function drawHand(dc, angle, length, width, scale_to_fenix as Number)
	{
		length = length * scale_to_fenix;
		width = width * scale_to_fenix;
		
		
		// Map out the coordinates of the watch hand
		var coords = [
			[-(width/2),0],
			[-(width/2), -length],
			[width/2, -length],
			[width/2, 0]
			];
		var result = new [4];
		var centerX = dc.getWidth() / 2;
		var centerY = dc.getHeight() / 2;
		var cos = Math.cos(angle);
		var sin = Math.sin(angle);
		
		// Transform the coordinates
		for (var i = 0; i < 4; i += 1)
		{
		var x = (coords[0] * cos) - (coords[1] * sin);
		var y = (coords[0] * sin) + (coords[1] * cos);
		result= [ centerX+x, centerY+y];
		}
		
		// Draw the polygon
		dc.fillPolygon(result);
		dc.fillPolygon(result);
	}
   
	// Solve complication
	function getComplicationString(input_string as String) as String {
		var dateStr = "";
		var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
		
		switch (input_string){
			case 0: // date
				var date_format = Application.getApp().Properties.getValue("date_format");
		        switch (date_format){
		        	case 0:
		        		dateStr = Lang.format("$1$/$2$", [info.day, info.month]);
		        		break;
		        	case 1:
		        		dateStr = Lang.format("$1$/$2$", [info.month, info.day]);
		        		break;
		        }
		        
	    		var dateView = View.findDrawableById("DateDisplay") as Text;
	    		return dateStr;
	    		break;
	    	case 1: // 1 battery
	    		var myStats = System.getSystemStats();
				var batStr = Lang.format( "$1$%", [ myStats.battery.format( "%2d" ) ] );
		        var batView = View.findDrawableById("BatteryDisplay") as Text;
		        return batStr;
	    		break;
	    	case 2: // 2 heartrate
	    		var hrStr = "--";
	    		var sample = Sensor.getHeartRateHistory( {:order=>Sensor.ORDER_NEWEST_FIRST}).next();
				if( sample != null) {
					if (sample.data != null){
						hrStr = sample.data.toString();
					}
				}
	    		if ((hrStr == null) || (hrStr == "null")){
	    			hrStr = "--";
	    		}
	    		return hrStr;
	    		break;
	    	case 3: // 3 steps
		        var steps = ActivityMonitor.getInfo().steps;
		        if (steps > 1000){
		        	steps = (steps/1000.0).format("%.1f")+"k";
		        }
		        return steps;
	    		break;
	    	case 4: // leave blank
	    		return "";
	    		break;
	    	default: // leave blank
	    		return "";
	    		break;
		}	
	}


    // Update the view
    function onUpdate(dc as Dc) as Void {
    	var lume_color = Graphics.COLOR_ORANGE;
    
		var scale_to_fenix = dc.getWidth().toFloat()/260;
		var hand_coord_centre = dc.getWidth()/2;
    
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

		// Enable anti-aliasing, if available
		if(dc has :setAntiAlias) {
			dc.setAntiAlias(true);
		}

		// Draw the tick marks around the edges of the screen
		dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
        drawHashMarks(dc, 60, 5, scale_to_fenix);
        drawMainNumbers(dc, scale_to_fenix);
        
        // Drawing the triangles around the dial
        dc.setColor(lume_color, Graphics.COLOR_TRANSPARENT);
        drawMainTriangles(dc, 4, 0, 15, 0, scale_to_fenix); // Count, skipper, thickness, shortener - all are scaled to fenix inside the function
        drawMainTriangles(dc, 12, 3, 12, -16, scale_to_fenix); // Count, skipper, thickness, shortener - all are scaled to fenix inside the function
		
	    
        // Computing hand angles, convert time to minutes and compute the angle.
        // Get current time
        var clockTime = System.getClockTime();
        var hourHandAngle = (((clockTime.hour % 12) * 60) + clockTime.min);
        hourHandAngle = hourHandAngle / (12 * 60.0);
        hourHandAngle = hourHandAngle * Math.PI * 2;
	    var minuteHandAngle = (clockTime.min / 60.0) * Math.PI * 2;
	    
	    // Complications - get settings value
    	var param_1_setting = Application.getApp().Properties.getValue("top_complication");
    	var param_2_setting = Application.getApp().Properties.getValue("bot_complication");
    	var complication_location = Application.getApp().Properties.getValue("complication_location");
    	var date_format = Application.getApp().Properties.getValue("date_format");

		// Compute the required string and save result
		var top_complication = getComplicationString(param_1_setting);
		var bottom_complication = getComplicationString(param_2_setting);
	
	    // Compute location for complication - average angle of hour/minute - PI
	    dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
	    var textrad = hand_coord_centre;
	    var textdist = 90 * scale_to_fenix;
	    var textangle = (hourHandAngle + minuteHandAngle )/2;
	    
	    // Set angle/location depending on setting
	    switch (complication_location){
	    	case 0: // rotating
			    textangle = (hourHandAngle + minuteHandAngle )/2;
			    if ((hourHandAngle - minuteHandAngle).abs() < Math.PI){ textangle = textangle + Math.PI; } 
			   	textangle = textangle - Math.PI/2;
			   	break;
	    	case 1: // 12 o clock
	    	    textangle = Math.PI*1.5;
	    		break;
	    	case 2: // 3 o clock
	    		textangle = 0;
	    		break;
	    	case 3: // 6 o clock
	    	    textangle = Math.PI/2;
	    		break;
	    	case 4: // 9 o clock
	    	    textangle = Math.PI;
	    		break;
	    
	    }
        var sY = textrad + (textrad - textdist ) * Math.sin(textangle);
        var sX = textrad + (textrad - textdist ) * Math.cos(textangle);
	    dc.drawText(sX, sY - 18*scale_to_fenix, Graphics.FONT_TINY, top_complication, Graphics.TEXT_JUSTIFY_CENTER);
	    dc.drawText(sX, sY + 2*scale_to_fenix, Graphics.FONT_TINY, bottom_complication, Graphics.TEXT_JUSTIFY_CENTER);

	    

		// Use gray to draw the hour and minute hands
		dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);        
        
        // Draw hands
        var minusradius = -10 * scale_to_fenix;
        var arrowstart = 70 * scale_to_fenix;
        dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
        
        // Hour hand base
        dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], hourHandAngle, 
        	80 * scale_to_fenix,
        	minusradius,
        	18 * scale_to_fenix,
        	5 * scale_to_fenix));
       	
		// Hour hand arrow tip	
        dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], hourHandAngle,
        	90*scale_to_fenix,
        	-arrowstart + 4*scale_to_fenix,
        	24 * scale_to_fenix,
        	3 * scale_to_fenix));
		
		// Minute hand
		dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], minuteHandAngle,
			125 * scale_to_fenix,
			minusradius,
			12 * scale_to_fenix,
			3 * scale_to_fenix));    

        
		// LUMES, hence changing to the right color
		dc.setColor(lume_color,Graphics.COLOR_TRANSPARENT);
		
		// Arrow tip lume - hour hand
        dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], hourHandAngle,
        	83 * scale_to_fenix,
        	-arrowstart,
        	14 * scale_to_fenix,
        	1 * scale_to_fenix));
        
        // Spike lume - minute hand
		dc.fillPolygon(generateHandCoordinates([hand_coord_centre, hand_coord_centre], minuteHandAngle,
			115 * scale_to_fenix,
			minusradius,
			6 * scale_to_fenix,
			1*scale_to_fenix));
         
	    // Center dot
	    dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
	    dc.fillCircle(hand_coord_centre, hand_coord_centre, -minusradius + 3 * scale_to_fenix);
	    dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
	    dc.drawCircle(hand_coord_centre, hand_coord_centre, -minusradius + 3 * scale_to_fenix);
	    
	
	    //onPartialUpdate(dc, minusradius); // Allows for second-hand creation later on
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
