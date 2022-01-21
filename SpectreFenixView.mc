import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;
import Toybox.Math;
import Toybox.Time;

class SpectreFenixView extends WatchUi.WatchFace {

	// Compute a scaler value to multiply all constants with, to be able to transfer the scale correctly between (round-face) models withn different screen resolutions
	// var scale_to_fenix = dc.getWidth/260;
	

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

    //! Draws the clock tick marks around the outside edges of the screen.
    //! @param dc Device context
    private function drawHashMarks(dc as Dc, count as Number, skip as Number) as Void {
    	var scale_to_fenix = dc.getWidth().toFloat()/260;
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

    private function drawMainNumbers(dc as Dc) as Void {
    	var scale_to_fenix = dc.getWidth().toFloat()/260;
        var width = dc.getWidth();
        var height = dc.getHeight();
        var outerRad = width / 2;
        var innerRad = outerRad - 25 * scale_to_fenix;
		var distfromside = 45 * scale_to_fenix;
		var textheight = 29 * scale_to_fenix;	
		

		dc.drawText(width/2, width-distfromside-textheight, Graphics.FONT_NUMBER_MILD, 6, Graphics.TEXT_JUSTIFY_CENTER);
		dc.drawText(width-distfromside, width/2-textheight, Graphics.FONT_NUMBER_MILD, 3, Graphics.TEXT_JUSTIFY_CENTER);
		dc.drawText(distfromside, width/2-textheight, Graphics.FONT_NUMBER_MILD, 9, Graphics.TEXT_JUSTIFY_CENTER);

		//dc.drawText(130, distfromside-textheight, Graphics.FONT_NUMBER_MILD, 12, Graphics.TEXT_JUSTIFY_CENTER);
		
		
		
		var triangle_width = 18 * scale_to_fenix;
		var triangle_height = 28 * scale_to_fenix;
		var triangle_spacer = -14 * scale_to_fenix;
		var triangle_eye_rad = 5 * scale_to_fenix;
		
		//dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
		dc.fillPolygon([[width/2, distfromside + triangle_spacer],[width/2 - triangle_width, distfromside + triangle_spacer + triangle_height],[width/2 + triangle_width, distfromside + triangle_spacer + triangle_height]]);
	    dc.fillCircle(width/2 - triangle_eye_rad - 9*scale_to_fenix, distfromside + triangle_spacer + 3, triangle_eye_rad);
	    dc.fillCircle(width/2 + triangle_eye_rad + 9*scale_to_fenix, distfromside + triangle_spacer + 3, triangle_eye_rad);

    }

    private function drawMainTriangles(dc as Dc, count as Number, skipper as Number, thickness as Number, shortener as Number) as Void {
    	var scale_to_fenix = dc.getWidth().toFloat()/260;
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


	function drawHand(dc, angle, length, width)
	{
		// Scale numbers with fenix scalar, so that arguments can follow fenix inputs
		var scale_to_fenix = dc.getWidth/260;
		
		length = length * scale_to_fenix;
		width = width * scale_to_fenix;
		
		
		// Map out the coordinates of the watch hand
		var coords = [ [-(width/2),0], [-(width/2), -length], [width/2, -length], [width/2, 0] ];
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
   

    // Update the view
    function onUpdate(dc as Dc) as Void {
		var scale_to_fenix = dc.getWidth().toFloat()/260;
    
        // Get current time
        var clockTime = System.getClockTime();

		// Battery count
		var myStats = System.getSystemStats();
		var batStr = Lang.format( "$1$%", [ myStats.battery.format( "%2d" ) ] );
        var batView = View.findDrawableById("BatteryDisplay") as Text;
        //batView.setText(batStr);

        // Date
        var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var dateStr = Lang.format("$1$/$2$", [info.day, info.month]);
        var dateView = View.findDrawableById("DateDisplay") as Text;
  

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);


		// Draw the tick marks around the edges of the screen
		dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
        drawHashMarks(dc, 60, 5);
        drawMainNumbers(dc);
        
        // Drawing the center circle and triangles around the dial
        dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);

        var minusradius = -10*scale_to_fenix;

        dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        drawMainTriangles(dc, 4, 0, 15, 0); // Count, skipper, thickness, shortener - all are scaled to fenix inside the function
        drawMainTriangles(dc, 12, 3, 12, -16); // Count, skipper, thickness, shortener - all are scaled to fenix inside the function
		
		
		
		// Use white to draw the hour and minute hands
		dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);

        // Draw the hour hand. Convert it to minutes and compute the angle.
        var hourHandAngle = (((clockTime.hour % 12) * 60) + clockTime.min);
        hourHandAngle = hourHandAngle / (12 * 60.0);
        hourHandAngle = hourHandAngle * Math.PI * 2;
	    var minuteHandAngle = (clockTime.min / 60.0) * Math.PI * 2;
        
        // Hour hand base silver
        dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateHandCoordinates([dc.getWidth()/2, dc.getWidth()/2], hourHandAngle, 80*scale_to_fenix, minusradius, 18*scale_to_fenix, 5*scale_to_fenix));
       	var arrowstart = 70*scale_to_fenix;
       	
		// Arrow silver bit       	
        dc.fillPolygon(generateHandCoordinates([dc.getWidth()/2, dc.getWidth()/2], hourHandAngle, 90*scale_to_fenix, -arrowstart + 4*scale_to_fenix, 24*scale_to_fenix, 3*scale_to_fenix));
        
        dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_TRANSPARENT);

		// Arrow lume
        dc.fillPolygon(generateHandCoordinates([dc.getWidth()/2, dc.getWidth()/2], hourHandAngle, 83*scale_to_fenix, -arrowstart, 14*scale_to_fenix, 1*scale_to_fenix));
        
        // Minute Hand
        dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateHandCoordinates([dc.getWidth()/2, dc.getWidth()/2], minuteHandAngle, 125*scale_to_fenix, minusradius, 12*scale_to_fenix, 3*scale_to_fenix));     
        dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateHandCoordinates([dc.getWidth()/2, dc.getWidth()/2], minuteHandAngle, 115*scale_to_fenix, minusradius, 6*scale_to_fenix, 1*scale_to_fenix));
	    
	    // Center dot
	    dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
	    dc.fillCircle(dc.getWidth()/2, dc.getWidth()/2, -minusradius + 3*scale_to_fenix);
	    dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_TRANSPARENT);
	    dc.drawCircle(dc.getWidth()/2, dc.getWidth()/2, -minusradius + 3 * scale_to_fenix);
	    
	    // Compute location for date - average angle of hour/minute - PI
	    dc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_TRANSPARENT);
	    var textrad = dc.getWidth()/2;
	    var textdist = 87*scale_to_fenix;
	    var textangle = (hourHandAngle + minuteHandAngle )/2;
	    if ((hourHandAngle - minuteHandAngle).abs() < Math.PI){ textangle = textangle + Math.PI; } 
	    
	    textangle = textangle - Math.PI/2;
        var sY = textrad + (textrad - textdist ) * Math.sin(textangle);
        var sX = textrad + (textrad - textdist ) * Math.cos(textangle);
	    dc.drawText(sX, sY + 2*scale_to_fenix, Graphics.FONT_TINY, batStr, Graphics.TEXT_JUSTIFY_CENTER);
	    dc.drawText(sX, sY - 18*scale_to_fenix, Graphics.FONT_TINY, dateStr, Graphics.TEXT_JUSTIFY_CENTER);
	    
	    
	    //onPartialUpdate(dc, minusradius);
    }
    
    // NOT used 
   	function onPartialUpdatePLACEHOLDER(dc as Dc, minusradius as Number) as Void {
	   	var clockTime = System.getClockTime();
        var secondAngle = clockTime.sec;
        secondAngle = secondAngle * (6);
        secondAngle = secondAngle * Math.PI / 180;
        //dc.fillPolygon(generateHandCoordinates([130, 130], secondAngle, 83, -50, 14, 1));
        var secrad = 130;
        var secballrad = 8;
        var Y = secrad + (secrad-secballrad-4) * Math.sin(secondAngle - Math.PI/2);
        var X = secrad + (secrad-secballrad-4) * Math.cos(secondAngle - Math.PI/2);
        
       	//var x = (coords[0] * cos) - (coords[1] * sin);
		//var y = (coords[0] * sin) + (coords[1] * cos);
        
        dc.setColor(Graphics.COLOR_LT_GRAY,Graphics.COLOR_TRANSPARENT);
        // Drawing the hand
        dc.fillPolygon(generateHandCoordinates([130, 130], secondAngle, secrad-secballrad-2, minusradius, 2, 2));
        
        // Drawing the second ball
	    dc.fillCircle(X, Y, secballrad);
	    dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_TRANSPARENT);
	    dc.fillCircle(X, Y, secballrad-3);
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

