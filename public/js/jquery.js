$(document).ready(function(){


	var key_capture = false
	var ip_address = "0.0.0.0";



	$.fn.sendData = function(val1, val2, val3, etc)
	{
		data = "val1=" + val1 + ", " + "val2=" + val2 + ", " + "val3=" + val3 + ", " + "etc=" + etc;
		fetch(("http://" + ip_address + ":80"), {
													method: 'POST',
													body: (data),
													credentials: 'same-origin'
									}).catch(function(err) {
													alert(err);
									});
	}


$("#ip_address_button").click(function(){
		ip_address = $("#ip_addr").val();
		$("#ip_addr").val("");
});

$("#send_button").click(function(){
		sendData($("#val1").val(), $("#val2").val(), $("#Val3").val(), $("#etc").val());
});






});
