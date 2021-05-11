
dockRelease = 0 -- 0 for latched, 1 for unlatched
backupArrest = 0 -- o for running, 1 for stopped
abort = 0 -- 0 for normal operation ,1 for abort
drServoPos = 0 -- Servo position for dock release, -1 if not being used
baServoPos = 0 -- Servo position for backup arrest, -1 if not being used
thrustPos = 0 -- thrust percentage of EDF
start = 0 -- start of mission, activates release from dock and activation of systems
restart = 0 -- resets system for another mission, 0 for normal state, 1 for reset.
powerCycle = 0 -- 0 for normal state, 1 for restarting the circuits
status={}

------------------------ Functions go below here
function setBackupArrest()
        --pwm duty cycle between 18 and 134
        if( baServoPos > 0) then
            pwm.setduty(5,baServoPos)   
        else
            if(backupArrest == 0) then
                    pwm.setduty(5,76)
                else
                    pwm.setduty(5,90)
                end
        end
end

function setDockRelease()
        --pwm duty cycle between 18 and 134
        if( drServoPos > 0) then
            pwm.setduty(6,drServoPos)   
        else
            if(dockRelease == 0) then
                    pwm.setduty(6,96)
                else
                    pwm.setduty(6,76)
                end
        end
end


function receiveData()
    -- A secondayr loop function, this function is called every time a web request is received
    -- Puts received data into variables and called any functions that will update the lander
    --   based on the new data
    dockRelease = tonumber(status.dockRelease)
    backupArrest = tonumber(status.backupArrest)
    abort = tonumber(status.abort)
    drServoPos = tonumber(status.drServoPos)
    baServoPos = tonumber(status.baServoPos)
    thrustPos = tonumber(status.thrustPos)
    start = tonumber(status.start)
    restart = tonumber(status.restart)
    powerCycle = tonumber(status.powerCycle)
end

function sendData()
    sendStr = "";
    sendStr = sendStr.. dockRelease..",";
    sendStr = sendStr.. backupArrest.. ",";
    sendStr = sendStr.. abort.. ",";
    sendStr = sendStr.. drServoPos.. ",";
    sendStr = sendStr.. baServoPos.. ",";
    sendStr = sendStr.. thrustPos.. ",";
    sendStr = sendStr.. start.. ",";
    sendStr = sendStr.. restart.. ",";
    sendStr = sendStr.. powerCycle;
    
    -- use .. instead of + when adding strings
    return sendStr
end

------------------------ Initialisation Code goes here

pwm.setup(5, 50, 76)
pwm.setup(6, 50, 76)
pwm.start(5)
pwm.start(6)
-- setting up pwm for servos
--setup function for communicating with atmega


function main()
    setBackupArrest()
    setDockRelease()

end




--Setup WiFi and other wifi related stuff below here
station_cfg={}
station_cfg.ssid="COVID-5G"
station_cfg.pwd="1300655506"
station_cfg.save=false
wifi.setmode(wifi.STATION, true)
wifi.sta.config(station_cfg)


sys = tmr.create()
sys:alarm(1000, tmr.ALARM_SEMI, function() 
    if wifi.sta.getip()== nil then 
        print("Looking for IP")
        sys:start()
    else
        print("Got IP. "..wifi.sta.getip())
        --create timer after getting ip address
        mainTmr = tmr.create()
        mainTmr:register(1000, tmr.ALARM_AUTO, function() main() end)
        if not mainTmr:start() then print("uh oh") end
        wifi.sta.sethostname("LANDER-ESP8266")
    end 
end)



srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    string_payload = tostring(payload)
    for k, v in string.gmatch( string_payload, "(%w+)=(%w+)" ) do
        status[k] = v
    end
    print(payload)
    receiveData()
    conn:send("HTTP/1.1 200 OK\n")
    conn:send("\r\n\n\n")
    conn:send(sendData())
  end)
  conn:on("sent",function(conn) conn:close() end)
end)
