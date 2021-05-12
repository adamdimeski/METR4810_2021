-- -------------------------- CONSTANTS / SETTINGS -------------------------- --
-- Constants is for things that will stay "constant" throughout execution

-- Wifi settings
wifiSsid = "Alex's iPhone 6"
wifiPwd = "ayylmao0"

-- Pin mappings
MOTOR_PIN = 5

BA_PIN = 6

DR_PIN = 5
DR_CLOSED_DUTY = 76
DR_OPEN_DUTY = 96

-- Misc
ZERO_DEG_DUTY = 52

-- ---------------------------- GLOBAL VARIABLES ---------------------------- --
-- Variables is for things that will change throughout execution

-- STATUS VARIABLES
dockRelease = 0 -- 0 for latched, 1 for unlatched
backupArrest = 0 -- 0 for running, 1 for stopped
abort = 0 -- 0 for normal operation ,1 for abort
drServoPos = 0 -- Servo position for dock release, -1 if not being used
baServoPos = 0 -- Servo position for backup arrest, -1 if not being used
thrustPos = 0 -- thrust percentage of EDF
start = 0 -- start of mission, activates release from dock and activation of systems
restart = 0 -- resets system for another mission, 0 for normal state, 1 for reset.
powerCycle = 0 -- 0 for normal state, 1 for restarting the circuits
status={}

-- -------------------------------- FUNCTIONS ------------------------------- --

function setBackupArrest()
    --pwm duty cycle between 18 and 134
    if( baServoPos > 0) then
        pwm.setduty(BA_PIN,baServoPos)
    else
        if(backupArrest == 0) then
            pwm.setduty(5,76)
        else
            pwm.setduty(5,90)
        end
    end
end

-- function setDockRelease()
--     -- WTF does this function do! no docs
--     --pwm duty cycle between 18 and 134
--     if( drServoPos > 0) then
--         pwm.setduty(BA_PIN,drServoPos)
--     else
--         if(dockRelease == 0) then
--             -- Set the dock release to the closed position
--             pwm.setduty(BA_PIN,DR_CLOSED_DUTY)
--         else
--             -- Set the dock release to the open position
--             pwm.setduty(BA_PIN,DR_OPEN_DUTY)
--         end
--     end
-- end


function receiveData()
    -- A secondary loop function, this function is called every time a web request is received
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
    -- Sends all the status bits to the website

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

function setAngle(pin, angle)
    -- Set the angle of a servo (0-180) (1ms-2ms pulse)
    -- Does nothing if given an angle outside 0-180

    if angle>0 and angle<180 then
        dutyTime = 1 + 1*(angle/180) -- time of pulse in ms
        dutyCycle = (dutyTime/20) * 1023 -- the duty cucle out of 1023
        pwm.setduty(MOTOR_PIN, dutyCycle) -- set the servo to the given angle
    end
    -- If angle out of range do nothing
end

function setupDockRelease()
    -- Sets up the docking release mechanism (starts in closed position)
    print("Setting up DR...")

    dockRelease = 12 -- set status (start with DR closed)
    pwm.setup(DR_PIN, 50, DR_CLOSED_DUTY) -- setup pwm settings (50Hz)
    pwm.start(DR_PIN) -- start sending pwm signal
end

function toggleDockRelease()
    -- Toggles the dock release mechanism open/closed
    -- pwm.stop(DR_PIN) -- start sending pwm signal

    print("Toggling...")
    if(dockRelease == 0) then
        -- If NOT currently released
        -- Set the dock release to the open position
        pwm.setduty(DR_PIN,DR_OPEN_DUTY) --DR_OPEN_DUTY
        -- Record our new status
        dockRelease = 1
    else
        -- If currently released
        -- Set the dock release to the closed position
        pwm.setduty(DR_PIN,DR_CLOSED_DUTY)
        -- Record our new status
        dockRelease = 0
    end
    -- pwm.start(DR_PIN) -- start sending pwm signal
end

-- function oneTimeSetup()
--     -- Setup motor
--     -- pwm.setup(MOTOR_PIN, 50, ZERO_DEG_DUTY)
--     -- Setup backup arrestor
--     -- pwm.setup(BA_PIN, 50, ZERO_DEG_DUTY)
--     -- -- pwm.start(MOTOR_PIN)
--     -- setAngle(BA_PIN, 0)
--     -- -- setting up pwm for servos
--     -- --...
-- end
-- --------------------------- ONE TIME SETUP CODE -------------------------- --

print("Doing one-time-setup...")

-- Setup docking release
setupDockRelease()
    
-- pwm.setup(DR_PIN, 50, DR_CLOSED_DUTY)
-- pwm.start(DR_PIN)
-- setting up pwm for servos
--setup function for communicating with atmega


-- -------------------------------- MAIN CODE ------------------------------- --


function main()
    print("Running main loop...")

    -- Toggle the docking release open/closed
    toggleDockRelease()

    print("dockRelease="..tostring(dockRelease))

    -- setBackupArrest()
    -- setDockRelease()
end

-- ----------------------- OTHER NETWORKING PROCESSES ----------------------- --

--Setup WiFi and other wifi related stuff below here
station_cfg={}
station_cfg.ssid=wifiSsid
station_cfg.pwd=wifiPwd
station_cfg.save=false
wifi.setmode(wifi.STATION, true)
wifi.sta.config(station_cfg)

-- Connect to wifi and setup the main loop
sys = tmr.create()
sys:alarm(1000, tmr.ALARM_SEMI, function()
    if wifi.sta.getip()== nil then
        -- If not connected to wifi yet
        print("Looking for IP")
        sys:start()
    else
        -- If connected to wifi
        print("Got IP. "..wifi.sta.getip())
        
        -- Setup the main loop with witchcraft
        -- oneTimeSetup()
        mainTmr = tmr.create()
        mainTmr:register(1000, tmr.ALARM_AUTO, function() main() end)
        if not mainTmr:start() then print("uh oh") end
        wifi.sta.sethostname("LANDER-ESP8266")
    end
end)

-- Start up the remote monitoring server
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive",function(conn,payload)

    -- Recieve data from the server
    string_payload = tostring(payload)
    for k, v in string.gmatch( string_payload, "(%w+)=(%w+)" ) do
        status[k] = v
    end

    print(payload) -- Print what the website sent
    receiveData() -- use the recieved data to repopulate our status variables
    -- print(status.abort)

    -- Send data to the server
    conn:send("HTTP/1.1 200 OK\n")
    conn:send("\r\n\n\n")
    conn:send(sendData()) -- send our current status variables to the website
  end)
  conn:on("sent",function(conn) conn:close() end)
end)
