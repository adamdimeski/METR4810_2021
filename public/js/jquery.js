var ip_address = "192.168.137.100";

var dockRelease = 0; // 0 for latched, 1 for unlatched
var backupArrest = 0; // o for running, 1 for stopped
var abort = 0; // 0 for normal operation ,1 for abort
var drServoPos = 0; // Servo position for dock release, -0 if not being used
var baServoPos = 0; // Servo position for backup arrest, 0 if not being used
var thrustPos = 0; // thrust percentage of EDF
var start = 0; // start of mission, activates release from dock and activation of systems
var stop = 0;
var restart = 0; // resets system for another mission, 0 for normal state, 1 for reset.
var powerCycle = 0; // 0 for normal state, 1 for restarting the circuits
var accX = 0; // acceleration data X-direction
var accY = 0; // acceleration data Y-direction
var accZ = 0; // acceleration data Z-direction
var pressure = 0; // Pressure data
var temperature = 0; // Temperature data
var errorF = 0; // error flag from lander

var accDataX = []; // acceleration data X-direction dataset for graphing
var accDataY = []; // acceleration data Y-direction dataset for graphing
var accDataZ = []; // acceleration data Z-direction dataset for graphing
var pressureData = []; // presssure dataset for graphing
var temperatureData = []; // temperature dataset for graphing
var xCount = 0; // Y-axis acount for graphing, based on refresh cyce of web requests
var plot = 1; // flag for plotting/not plotting

var accXOffset = 240; //accleration offset due to gravity
var accYOffset = 20; // acceleration offset due to gravity
var accZOffset = 108; // accleration offset due to gravity
var accMultiplier = 0.004; // scalar value for acclerometer readings

//Do not add these variables to the FETCH request
var autoupdate = 0; // auto update flag, 0, for stopped, 1 for auto-update
var autoRefreshInterval = 200; //refresh interval of auto fetch requests, milliseconds



// Function unpackes response received from the lander into the mission variables
function receiveData(csv)
{
	dockRelease = parseInt(csv[0]);
	thrustPos = parseInt(csv[1]);
	accX = (parseInt(csv[2]) - accXOffset) * accMultiplier; // correction of acceleration data
	accY = (parseInt(csv[3]) + accYOffset) * accMultiplier; // correction of acceleration data
	accZ = (parseInt(csv[4]) + accZOffset) * accMultiplier; // correction of acceleration data
	pressure = parseInt(csv[5])/100;
	temperature = parseInt(csv[6]);
	errorF = parseInt(csv[7]);
	// if plot flag is true, the telemetry data is plotted
	if (plot == 1)
	{
	  accDataX.push({x: (xCount * autoRefreshInterval * 0.001), y: accX});
		accDataY.push({x: (xCount * autoRefreshInterval * 0.001), y: accY});
		accDataZ.push({x: (xCount * autoRefreshInterval * 0.001), y: accZ});
		pressureData.push({x: (xCount * autoRefreshInterval * 0.001), y: pressure});
		temperatureData.push({x: (xCount * autoRefreshInterval * 0.001), y: temperature});
		xCount = xCount + 1; //time increment is increased
		$("#chartContainerAcc").CanvasJSChart().render()
		$("#chartContainerPressure").CanvasJSChart().render()
		$("#chartContainerTemperature").CanvasJSChart().render()
	}
	//If an error is flagged by the lander, it shown to the user
	if(errorF == 1) {
		$("#errortxt").text("TRUE");
	}
}


//fetch request send to lander in the form of POST request. Allows same origin requests
async function sendData()
{
	//send string is assembled
	data = "dockRelease=" + dockRelease + ", " + "abort=" + abort + ", " + "drServoPos=" + drServoPos + ", "
  + "thrustPos=" + thrustPos + ", " + "start=" + start + ", " + "stop=" + stop + ", " + "restart=" + restart + ", " + "powerCycle=" + powerCycle;

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
										console.log(response)
									}).catch(function(err) {
													alert(err);
									});
			}
			catch(err) {
  		console.log(err.message);
			}

}

/**(async() => {
    await sendData();
})();**/


//Canvas.js graphing settings and initialisation
var optionsAcc = {
	theme: "dark2",
	backgroundColor: "rgba(0,0,0,0.4)",
	title: {
		text: "Acceleration",
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	axisX:{
 		title:"Time (Seconds)",
		gridThickness: 0,
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	axisY:{
 		title:"Acceleration (G)",
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
	backgroundColor: "rgba(0,0,0,0.4)",
	title: {
		text: "Pressure",
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	axisX:{
 		title:"Time (Seconds)",
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
	backgroundColor: "rgba(0,0,0,0.4)",
	cornerRadius: 4,
	title: {
		text: "Temperature",
		fontFamily: "Open Sans",
		fontType: "sans-serif"
	},
	axisX:{
 		title:"Time (Seconds)",
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

//Graphs initialised
$(function () {
	$("#chartContainerAcc").CanvasJSChart(optionsAcc);
	$("#chartContainerPressure").CanvasJSChart(optionsPressure);
	$("#chartContainerTemperature").CanvasJSChart(optionsTemperature);
});




//Jquery reeady function that contains event handlers and auto-refresh function
$(document).ready(function(){
	$("#ipAdresstxt").text(ip_address);

	//Sends a fetch request on an interval if the auto-update flag is true
	function refresh()
	{
		thrustPos = $("#thrustAdjust").val();
		$("#thrusttxt").text(thrustPos);
		$('#slider').roundSlider('setValue', thrustPos + " %");
		if(autoupdate != 0)
		{
			sendData();

		}

		$("#temptxt").text(temperature + " °C");
		//getting data and plotting it

		if(dockRelease != 0)
		{
			$("#dockingtxt").text("UNLOCKED");
		}
		else
		{
			$("#dockingtxt").text("LOCKED");
		}
	}

	setInterval(function(){refresh();},autoRefreshInterval);

//Button click event handlers
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

$("#startBtn").click(function(){
	start = 1;
	stop = 0;
	restart = 0;
	autoupdate = 1;
	dockRelease = 1;
	$("#statustxt").text("STARTED");
	$("#dockingtxt").text("UNLOCKED");
	sendData();
});

$("#stopBtn").click(function(){
	start = 0;
	restart = 0;
	stop = 1;
	autoupdate = 0;
	$("#statustxt").text("STOPPED");
	sendData();
});

$("#restartBtn").click(function(){
	restart = 1;
	start = 0;
	stop = 0;
	thrustPos = 0;
	dockRelease = 0;
	abort = 0;
	powerCycle = 0;
	autoupdate = 0;
	errorF = 0
	$("#errortxt").text("FALSE");
	$("#statustxt").text("RESTARTED");
	$("#dockingtxt").text("LOCKED");
	sendData();
});

$("#abortBtn").click(function(){
	abort = 1
	$("#statustxt").text("ABORTED");
	sendData();
});

$("#powerCycleBtn").click(function(){
	powerCycle = 1
	$("#statustxt").text("Power Cycle Triggered");
	sendData();
});

$("#thrustAdjust").click(function(){
	thrustPos = $("#thrustAdjust").val();
	$("#thrusttxt").text(thrustPos);
	$('#slider').roundSlider('setValue', thrustPos + " %");
	sendData();
});
$("#idleBtn").click(function(){
	restart = 0;
	start = 0;
	stop = 0;
	thrustPos = 0;
	abort = 0;
	powerCycle = 0;
	autoupdate = 0;
	$("#statustxt").text("IDLE");
	sendData();
});


});
