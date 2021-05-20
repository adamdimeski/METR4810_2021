var ip_address = "192.168.137.100";

var dockRelease = 1; // 0 for latched, 1 for unlatched
var backupArrest = 0; // o for running, 1 for stopped
var abort = 0; // 0 for normal operation ,1 for abort
var drServoPos = 0; // Servo position for dock release, -0 if not being used
var baServoPos = 0; // Servo position for backup arrest, 0 if not being used
var thrustPos = 0; // thrust percentage of EDF
var start = 0; // start of mission, activates release from dock and activation of systems
var restart = 0; // resets system for another mission, 0 for normal state, 1 for reset.
var powerCycle = 0; // 0 for normal state, 1 for restarting the circuits
var accX = [];
var accY = [];
var accZ = [];
var temp = 0;


//Do not add these variables to the FETCH request
var autoupdate = 0;
var autoRefreshInterval = 1000; //milliseconds

//add more variables here
// no negative numbers

function receiveData(csv)
{
	dockRelease = parseInt(csv[0]);
	abort = parseInt(csv[1]);
	drServoPos = parseInt(csv[2]);
	thrustPos = parseInt(csv[3]);
	start = parseInt(csv[4]);
	restart = parseInt(csv[5]);
	accX.push(parseInt(csv[6]));
	accY.push(parseInt(csv[7]));
	accZ.push(parseInt(csv[8]));
	temp = parseInt(csv[9]);

	//add more variables and unpack from data by incrementing the value in data
}

async function sendData()
{
	data = "dockRelease=" + dockRelease + ", " + "abort=" + abort + ", " + "drServoPos=" + drServoPos + ", "
  + "thrustPos=" + thrustPos + ", " + "start=" + start + ", " + "restart=" + restart;

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

	setInterval(function(){refresh();},1000);


$("#ip_address_button").click(function(){
		ip_address = $("#ip_addr").val();
		$("#ipAdresstxt").text(ip_address);
		$("#ip_addr").val("");
});

$("#dockActivateBtn").click(function(){
		dockRelease = 1;
		$("#dockingtxt").text("ENABLED");
		dockingtxt
		sendData();
});

$("#dockDeactivateBtn").click(function(){
		dockRelease = 0;
		$("#dockingtxt").text("DISABLED");
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

});
