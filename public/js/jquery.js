var ip_address = "192.168.137.190";

var dockRelease = 1; // 0 for latched, 1 for unlatched
var backupArrest = 0; // o for running, 1 for stopped
var abort = 0; // 0 for normal operation ,1 for abort
var drServoPos = -1; // Servo position for dock release, -1 if not being used
var baServoPos = -1; // Servo position for backup arrest, -1 if not being used
var thrustPos = 0; // thrust percentage of EDF
var start = 0; // start of mission, activates release from dock and activation of systems
var restart = 0; // resets system for another mission, 0 for normal state, 1 for reset.
var powerCycle = 0; // 0 for normal state, 1 for restarting the circuits

async function sendData()
{
	data = "dockRelease=" + dockRelease + ", " + "backupArrest=" + backupArrest + ", " + "abort=" + abort + ", " + "drServoPos=" + drServoPos + ", "
	+ "baServoPos=" + baServoPos + ", " + "thrustPos=" + thrustPos + ", " + "start=" + start + ", " + "restart=" + restart + ", " + "powerCycle=" + powerCycle;

	fetch(("http://" + ip_address + ":80"), {
												method: 'POST',
												body: (data),
												credentials: 'same-origin'
								}).then(response => response.text())
        				.then((response) => {
            			console.log(response)
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

$("#send").click(function(){
		sendData();
});


});
