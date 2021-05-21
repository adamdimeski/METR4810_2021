var ip_address = "192.168.137.100";

var dockRelease = 1; // 0 for latched, 1 for unlatched
var backupArrest = 0; // o for running, 1 for stopped
var abort = 0; // 0 for normal operation ,1 for abort
var drServoPos = 0; // Servo position for dock release, -0 if not being used
var baServoPos = 0; // Servo position for backup arrest, 0 if not being used
var thrustPos = 0; // thrust percentage of EDF
var start = 0; // start of mission, activates release from dock and activation of systems
var stop = 0;
var restart = 0; // resets system for another mission, 0 for normal state, 1 for reset.
var powerCycle = 0; // 0 for normal state, 1 for restarting the circuits
var accX = 0;
var accY = 0;
var accZ = 0;
var pressure = 0;
var temperature = 0;

var accDataX = [];
var accDataY = [];
var accDataZ = [];
var pressureData = [];
var temperatureData = [];
var xCount = 0;
var plot = 1;
//Do not add these variables to the FETCH request
var autoupdate = 0;
var autoRefreshInterval = 100; //milliseconds


//add more variables here
// no negative numbers

function receiveData(csv)
{
	dockRelease = parseInt(csv[0]);
	abort = parseInt(csv[1]);
	drServoPos = parseInt(csv[2]);
	thrustPos = parseInt(csv[3]);
	start = parseInt(csv[4]);
	stop = parseInt(csv[5]);
	restart = parseInt(csv[6]);
	accX = parseInt(csv[7]);
	accY = parseInt(csv[8]);
	accZ = parseInt(csv[9]);
	pressure = parseInt(csv[10])/100;
	temperature = parseInt(csv[11]);
	if (plot == 1)
	{
	  accDataX.push({x: xCount, y: accX});
		accDataY.push({x: xCount, y: accY});
		accDataZ.push({x: xCount, y: accZ});
		pressureData.push({x: xCount, y: pressure});
		temperatureData.push({x: xCount, y: temperature});
		xCount = xCount + 1;
		console.log(xCount)
		$("#chartContainerAcc").CanvasJSChart().render()
		$("#chartContainerPressure").CanvasJSChart().render()
		$("#chartContainerTemperature").CanvasJSChart().render()
	}
	//add more variables and unpack from data by incrementing the value in data
}

async function sendData()
{
	data = "dockRelease=" + dockRelease + ", " + "abort=" + abort + ", " + "drServoPos=" + drServoPos + ", "
  + "thrustPos=" + thrustPos + ", " + "start=" + start + ", " + "stop=" + stop + ", " + "restart=" + restart;

	//add more variables to the string above to send to the microcontroller

	try {
		fetch(("http://" + ip_address + ":80"), {
													method: 'POST',
													body: (data),
													credentials: 'same-origin'
									}).then(response => response.text())
	        				.then((response) => {
										csv = $.csv.toArray(response);
										receiveData(csv)
										console.log(accX)
										console.log(accY)
										console.log(accZ)
	            			console.log(data)
									}).catch(function(err) {
													alert(err);
									});
			}
			catch(err) {
  		console.log(err.message);
			}

}

(async() => {
    await sendData();
})();



var optionsAcc = {
	theme: "dark2",
	title: {
		text: "Acceleration",
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	axisX:{
 		title:"Time (100 Milliseconds)",
		gridThickness: 0,
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	axisY:{
 		title:"Acceleration",
		gridThickness: 0,
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	legend: {
       horizontalAlign: "center", // "center" , "right"
       verticalAlign: "bottom",
			 fontFamily: "Open Sans",
	 			fontType: "sans-serif"  // "top" , "bottom"
     },
	data: [{
		type: "line",
		name: "X",
		showInLegend: true,
		dataPoints: accDataX
	},
	{
		type: "line",
		name: "Y",
		showInLegend: true,
		dataPoints: accDataY
	},
	{
		type: "line",
		name: "Z",
		showInLegend: true,
		dataPoints: accDataZ
	}
]
};

var optionsPressure = {
	theme: "dark2",
	title: {
		text: "Pressure",
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	axisX:{
 		title:"Time (100 Milliseconds)",
		gridThickness: 0,
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	axisY:{
 		title:"Pressure (hPa)",
		gridThickness: 0,
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	legend: {
       horizontalAlign: "center", // "center" , "right"
       verticalAlign: "bottom",  // "top" , "bottom"
			 fontFamily: "Open Sans",
	 		fontType: "sans-serif"
     },
	data: [{
		type: "line",
		name: "Pressure (hPa)",
		showInLegend: true,
		dataPoints: pressureData
	}]
};

var optionsTemperature = {
	theme: "dark2",
	title: {
		text: "Temperature",
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	axisX:{
 		title:"Time (100 Milliseconds)",
		gridThickness: 0,
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	axisY:{
 		title:"Temperature (°C)",
		gridThickness: 0,
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	legend: {
       horizontalAlign: "center", // "center" , "right"
       verticalAlign: "bottom",  // "top" , "bottom"
			 fontFamily: "Open Sans",
	 		fontType: "sans-serif"
     },
	data: [{
		type: "line",
		name: "Temperature (°C)",
		showInLegend: true,
		dataPoints: temperatureData
	}]
};
$(function () {
	$("#chartContainerAcc").CanvasJSChart(optionsAcc);
	$("#chartContainerPressure").CanvasJSChart(optionsPressure);
	$("#chartContainerTemperature").CanvasJSChart(optionsTemperature);
});




$(document).ready(function(){
	$("#ipAdresstxt").text(ip_address);

	function refresh()
	{
		if(autoupdate != 0)
		{
			thrustPos = $("#thrustAdjust").val();
			$("#thrusttxt").text(thrustPos);

			sendData();
			$("#temptxt").text(temp + " °C");
			//getting data and plotting it

			if(dockRelease != 0)
			{
				$("#dockingtxt").text("ENABLED");
			}
			else
			{
				$("#dockingtxt").text("DISABLED");
			}



		}
	}

	setInterval(function(){refresh();},autoRefreshInterval);


$("#ip_address_button").click(function(){
		ip_address = $("#ip_addr").val();
		$("#ipAdresstxt").text(ip_address);
		$("#ip_addr").val("");
});

$("#dockActivateBtn").click(function(){
		dockRelease = 1;
		$("#dockingtxt").text("UNLOCKED");
		dockingtxt
		sendData();
});

$("#dockDeactivateBtn").click(function(){
		dockRelease = 0;
		$("#dockingtxt").text("LOCKED");
		sendData();
});


$("#autoRefreshbtn").click(function(){
		if (autoupdate != 0)
		{
			autoupdate = 0
			$("#autoRefreshtxt").text("OFF");
		}
		else
		{
			autoupdate = 1
			$("#autoRefreshtxt").text("ON");
		}
});

$("#clearPlotBtn").click(function(){
	accDataX.length = 0;
	accDataY.length = 0;
	accDataZ.length = 0;
	pressureData.length = 0;
	temperatureData.length = 0;
	xCount = 0;
	$("#chartContainerAcc").CanvasJSChart().render()
	$("#chartContainerPressure").CanvasJSChart().render()
	$("#chartContainerTemperature").CanvasJSChart().render()
});

$("#startPlotBtn").click(function(){
	plot = 1
});
$("#stopPlotBtn").click(function(){
	plot = 0
});

});
