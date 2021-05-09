ts_dir = 0
ts_dc = 0
ts_stop = 0
servo_pos = 50


dockRelease = 0 -- 0 for latched, 1 for unlatched
backupArrest = 0 -- o for running, 1 for stopped
abort = 0 -- 0 for normal operation ,1 for abort
drServoPos = -1 -- Servo position for dock release, -1 if not being used
baServoPos = -1 -- Servo position for backup arrest, -1 if not being used
thrustPos = 0 -- thrust percentage of EDF
start = 0 -- start of mission, activates release from dock and activation of systems
restart = 0 -- resets system for another mission, 0 for normal state, 1 for reset.
powerCycle = 0 -- 0 for normal state, 1 for restarting the circuits
status={}

------------------------ Functions go below here

function setThrust(thrustPos)

    
end

function setBA(backupArrest)

end

function setDR(dockRelease)

end

function setBAPos(baServoPos)

end

function setDRPos(drServoPos)

end


function update_status()
    -- A secondayr loop function, this function is called every time a web request is received
    -- Puts received data into variables and called any functions that will update the lander
    --   based on the new data
    dockRelease = tonumber(status["dockRelease"])
    backupArrest = tonumber(status["backupArrest"])
    abort = tonumber(status["abort"])
    drServoPos = tonumber(status["drServoPoso"])
    baServoPos = tonumber(status["baServoPos"])
    thrustPos = tonumber(status["thrustPos"])
    start = tonumber(status["start"])
    restart = tonumber(status["restart"])
    
    
end


------------------------ Initialisation Code goes here
-- setting up pwm for servos
--setup function for communicating with atmega



--Setup WiFi and other wifi related stuff below here
station_cfg={}
station_cfg.ssid="COVID-5G"
station_cfg.pwd="1300655506"
station_cfg.save=false
wifi.sta.config(station_cfg)


sys = tmr.create()
sys:alarm(1000, tmr.ALARM_SEMI, function() 
    if wifi.sta.getip()== nil then 
        print("Looking for IP")
        sys:start()
    else
        print("Got IP. "..wifi.sta.getip())
    end 
end)

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    string_payload = tostring(payload)
    --for k, v in string.gmatch( string_payload, "(%w+)=(%w+)" ) do
        --status[k] = v
    --end
    print(payload)
    --update_status()
    
    conn:send("HTTP/1.1 200 OK\n")
    conn:send("\r\n\n\n")
    conn:send("Whoomp there it is") 
  end)
  conn:on("sent",function(conn) conn:close() end)
end)
