$(document).ready(function(){


	var key_capture = false
	var ip_address = "0.0.0.0";



	$.fn.sendData = function(rw, ts_speed, ts_dir, ts_stop, servo_pos, ch1_speed, ch1_dir)
	{
		data = "rw=" + rw + ", " + "tsSpeed=" + ts_speed + ", " + "tsDir=" + ts_dir + ", " + "tsStop=" + ts_stop + ", "
		+ "servoPos=" + servo_pos + ", " + "ch1Speed=" + ch1_speed + ", " + "ch1Dir=" + ch1_dir;
		fetch(("http://" + ip_address + ":80"), {
													method: 'POST',
													body: (data),
													credentials: 'same-origin'
									}).catch(function(err) {
													alert(err);
									});
	}




	$(document).keypress(function(e) {
		if(key_capture)
		{
			if(e.which == 44) { //TS_LEFT <
				http_ts_speed = http_ts_speed - 10;
				if(http_ts_speed < 0)
				{
					http_ts_dir = 0;
				}
				else {
						http_ts_dir = 1;

				}
				if(http_ts_speed > 100)
				{
					http_ts_speed = 100;
				}
				if(http_ts_speed < -100)
				{
					http_ts_speed = -100;
				}
		     $.fn.sendData(0, Math.abs(http_ts_speed),http_ts_dir,0,http_servo_pos,0,0);
		  }

			if(e.which == 46) { //TS_RIGHT >
				http_ts_speed = http_ts_speed + 10;
				if(http_ts_speed < 0)
				{
					http_ts_dir = 0;
				}
				else {
						http_ts_dir = 1;

				}
				if(http_ts_speed > 100)
				{
					http_ts_speed = 100;
				}
				if(http_ts_speed < -100)
				{
					http_ts_speed = -100;
				}
		     $.fn.sendData(0,Math.abs(http_ts_speed),http_ts_dir,0,http_servo_pos,0,0);
		  }

			if(e.which == 119) { // UP W
					http_servo_pos = http_servo_pos + 5;
			   $.fn.sendData(0,Math.abs(http_ts_speed),http_ts_dir,0,http_servo_pos,0,0);
		  }

			if(e.which == 115) { // DOWN S
					http_servo_pos = http_servo_pos - 5;
		    	$.fn.sendData(0,Math.abs(http_ts_speed),http_ts_dir,0,http_servo_pos,0,0);
		  }
			if(e.which == 97) { // STRECTCH A
		     $.fn.sendData(0,Math.abs(http_ts_speed),http_ts_dir,0,http_servo_pos,0,0);
		  }
			if(e.which == 100) { // SQUEEZE D
		    $.fn.sendData(0,Math.abs(http_ts_speed),http_ts_dir,0,http_servo_pos,0,0);
		  }

			if(e.which == 32) { // SpaceBar full stop
				http_ts_speed = 0;
				http_ts_dir = 0;
				http_servo_pos = 50;
		    $.fn.sendData(0,0,0,0,0,0,0);
		  }
			if(e.which == 116) { // CHANGE TRACK T
				$myCanvas.clearCanvas();
				if(tc_left == 0)
				{
					tc_left = 1;
					pos_1.pause()
					pos_2.load();
					pos_2.play();
					$myCanvas.drawLine({
						strokeStyle: 'grey',
						strokeWidth: 7,
						x1: 102, y1: 97, //use y1 = 60 or 100
						x2: 117, y2: 77,
					});

				}
				else
				{
					tc_left = 0;
					pos_2.pause()
					pos_1.load();
					pos_1.play();
					$myCanvas.drawLine({
						strokeStyle: 'grey',
						strokeWidth: 7,
						x1: 102, y1: 55, //use y1 = 60 or 100
						x2: 117, y2: 75,
					});
				}
		  }
		}

	});

	$("#keycapture_button").click(function(){
		if(key_capture)
		{
			key_capture = false;
			$("#keycapture_button").css("background-color", "red");
			$("#keycapture_button").text("Disabled");
		}
		else
		{
			key_capture = true;
			$("#keycapture_button").css("background-color", "green");
			$("#keycapture_button").text("Enabled");
		}
});

$("#ip_address_button").click(function(){
		ip_address = $("#ip_addr").val();
		$("#ip_addr").val("");
});






});
