var ip_address = "192.168.137.190";

var dockRelease = 1; // 0 for latched, 1 for unlatched
var backupArrest = 0; // o for running, 1 for stopped
var abort = 0; // 0 for normal operation ,1 for abort
var drServoPos = 0; // Servo position for dock release, -0 if not being used
var baServoPos = 0; // Servo position for backup arrest, 0 if not being used
var thrustPos = 0; // thrust percentage of EDF
var start = 0; // start of mission, activates release from dock and activation of systems
var restart = 0; // resets system for another mission, 0 for normal state, 1 for reset.
var powerCycle = 0; // 0 for normal state, 1 for restarting the circuits

//add more variables here
// no negative numbers

function receiveData(csv)
{
	dockRelease = parseInt(csv[0]);
	backupArrest = parseInt(csv[1]);
	abort = parseInt(csv[2]);
	drServoPos = parseInt(csv[3]);
	baServoPos = parseInt(csv[4]);
	thrustPos = parseInt(csv[5]);
	start = parseInt(csv[6]);
	restart = parseInt(csv[7]);
	powerCycle = parseInt(csv[8]);

	//add more variables and unpack from data by incrementing the value in data
}

async function sendData()
{
	data = "dockRelease=" + dockRelease + ", " + "backupArrest=" + backupArrest + ", " + "abort=" + abort + ", " + "drServoPos=" + drServoPos + ", "
	+ "baServoPos=" + baServoPos + ", " + "thrustPos=" + thrustPos + ", " + "start=" + start + ", " + "restart=" + restart + ", " + "powerCycle=" + powerCycle;

	//add more variables to the string above to send to the microcontroller

	fetch(("http://" + ip_address + ":80"), {
												method: 'POST',
												body: (data),
												credentials: 'same-origin'
								}).then(response => response.text())
        				.then((response) => {
									csv = $.csv.toArray(response);
									receiveData(csv)
            			console.log(data)
								}).catch(function(err) {
												alert(err);
								});
}

(async() => {
    await sendData();
})();

$(document).ready(function(){


$("#ip_address_button").click(function(){
		ip_address = $("#ip_addr").val();
		$("#ip_addr").val("");
});

$("#abortActivateBtn").click(function(){
		abort = 1;
		sendData();
});

$("#abortDeactivateBtn").click(function(){
		abort = 0;
		sendData();
});


$("#send").click(function(){
		sendData();
});


});
