-- ###############################################################
-- secrity.lua - functions to support reed switch magnetic door and
-- window normally-open, which will be part of a security system.
--
-- Note: these are just dumb sensors programmed to insert their
-- values into the local network MQTT queue (aka topic). The 
-- Raspberry Pi (either the one running the broker or another one)
-- has all the smarts about what to do with the data in the topic
-- queue.
--
-- Note 2: I'll be improving this code as I learn more about Lua.
-- I recommend the book "Programming in Lua" by Roberto
-- Ierusalimschy (one of the designers of Lua).
--
-- Phil Moyer
-- Adafruit
-- 
-- May 2016
--
-- This code is open source, released under the BSD license. All
-- redistribution must include this header.
-- ###############################################################


-- ###############################################################
-- Global variables and parameters.
-- ###############################################################

sensorID = "security_001"	-- a sensor identifier for this device
tgtHost = "MQTT_BROKER_IP_ADDR"	-- target host (broker)
tgtPort = 1883			-- target port (broker listening on)
mqttUserID = "MQTT_USER_ID"		-- account to use to log into the broker
mqttPass = "MQTT_USER_PASSWORD"		-- broker account password
mqttTimeOut = 120		-- connection timeout
dataInt = 1			-- data transmission interval in seconds
topicQueue = "/security"	-- the MQTT topic queue to use

-- You shouldn't need to change anything below this line. -Phil --

-- ###############################################################
-- Functions
-- ###############################################################

-- Function pubEvent() publishes the sensor value to the defined queue.

function pubEvent()
	rv = adc.read(0)				-- read light sensor
	pubValue = sensorID .. " " .. rv		-- build buffer
	print("Publishing to " .. topicQueue .. ": " .. pubValue)	-- print a status message
	mqttBroker:publish(topicQueue, pubValue, 0, 0)	-- publish
end


-- Reconnect to MQTT when we receive an "offline" message.

function reconn()
	print("Disconnected, reconnecting....")
	conn()
end


-- Establish a connection to the MQTT broker with the configured parameters.

function conn()
	print("Making connection to MQTT broker")
	mqttBroker:connect(tgtHost, tgtPort, 0, function(client) print ("connected") end, function(client, reason) print("failed reason: "..reason) end)
end


-- Call this first! --
-- makeConn() instantiates the MQTT control object, sets up callbacks,
-- connects to the broker, and then uses the timer to send sensor data.
-- This is the "main" function in this library. This should be called 
-- from init.lua (which runs on the ESP8266 at boot), but only after
-- it's been vigorously debugged. 
--
-- Note: once you call this from init.lua the only way to change the
-- program on your ESP8266 will be to reflash the NodeCMU firmware! 

function makeConn()
	-- Instantiate a global MQTT client object
	print("Instantiating mqttBroker")
	mqttBroker = mqtt.Client(sensorID, mqttTimeOut, mqttUserID, mqttPass, 1)

	-- Set up the event callbacks
	print("Setting up callbacks")
	mqttBroker:on("connect", function(client) print ("connected") end)
	mqttBroker:on("offline", reconn)

	-- Connect to the Broker
	conn()

	-- Use the watchdog to call our sensor publication routine
	-- every dataInt seconds to send the sensor data to the 
	-- appropriate topic in MQTT.
	tmr.alarm(0, (dataInt * 1000), 1, pubEvent)
end


-- ###############################################################
-- "Main"
-- ###############################################################

-- No content. -prm