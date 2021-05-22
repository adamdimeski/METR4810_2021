-- -------------------------- CONSTANTS / SETTINGS -------------------------- --
-- Constants is for things that will stay "constant" throughout execution

-- Wifi settings
wifiSsid = "COVID-5G"
wifiPwd = "1300655506"

-- Pin mappings

DR_PIN = 5
DR_OPEN_DUTY = 69
DR_CLOSED_DUTY = 98

-- Misc
ZERO_DEG_DUTY = 52
-- Thruster
TH_PIN = 6
TH_START_DUTY = 50

sda, scl = 1, 2

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
stop = 0
restart = 0 -- resets system for another mission, 0 for normal state, 1 for reset.
powerCycle = 0 -- 0 for normal state, 1 for restarting the circuits
accX = 0
accY = 0
accZ = 0
temp = 0
pressure = 0
status={}
noi2c = 0 -- 0 for operation, 1 for non-operation
errorF = 0

-- -------------------------------------------------------------------------- --
--                                  FUNCTIONS                                 --
-- -------------------------------------------------------------------------- --

-- ------------------------------ BACKUP ARREST ----------------------------- --

-- ------------------------------ COMMUNICATION ----------------------------- --

function receiveData()
    -- A secondary loop function, this function is called every time a web request is received
    -- Puts received data into variables and called any functions that will update the lander
    --   based on the new data

    dockRelease = tonumber(status.dockRelease)
    abort = tonumber(status.abort)
    drServoPos = tonumber(status.drServoPos)
    thrustPos = tonumber(status.thrustPos)
    start = tonumber(status.start)
    stop = tonumber(status.stop)
    restart = tonumber(status.restart)
    powerCycle = tonumber(status.powerCycle)
end

function receiveDataErrorWrapper()
    if (pcall(receiveData) == false) then
        print("error thrown with nil value in receive data; IDLEING")
        dockRelease = 0
        abort = 0
        drServoPos = 0
        thrustPos = 0
        start = 0
        stop = 0
        restart = 0
        powerCycle = 0
        errorF = 1
    end
end

function sendData()
    -- Sends all the status bits to the website

    sendStr = "";
    sendStr = sendStr.. dockRelease..",";
    sendStr = sendStr.. thrustPos.. ",";
    sendStr = sendStr.. accX.. ",";
    sendStr = sendStr.. accY.. ",";
    sendStr = sendStr.. accZ.. ",";
    sendStr = sendStr.. pressure.. ",";
    sendStr = sendStr.. temp.. ",";
    sendStr = sendStr.. errorF;

    -- use .. instead of + when adding strings
    return sendStr
end

function sendDataErrorWrapper()
    error,sendStr = pcall(sendData)
    if (error == false) then
        print("error thrown with nil value in send data; IDLEING")
        sendStr = "";
        sendStr = sendStr.. "0"..",";
        sendStr = sendStr.. "0".. ",";
        sendStr = sendStr.. "0".. ",";
        sendStr = sendStr.. "0".. ",";
        sendStr = sendStr.. "0".. ",";
        sendStr = sendStr.. "0".. ",";
        sendStr = sendStr.. "0".. ",";
        sendStr = sendStr.. "1";
    end
    return sendStr
end


-- ----------------------------- DOCKING RELEASE ---------------------------- --


function updateDockRelease()
    -- Updates the dock release mechanism open/closed based on our desired dockRelease status

    if(dockRelease == 0) then
        -- If we should be closed
        -- Set the dock release to the closed position
        pwm.setduty(DR_PIN,DR_CLOSED_DUTY) --DR_OPEN_DUTY
    else
        -- If we should be open
        -- Set the dock release to the open position
        pwm.setduty(DR_PIN,DR_OPEN_DUTY)
    end
end

function i2cSetup()
    i2c.setup(0, sda, scl, i2c.SLOW)  -- call i2c.setup() only once
    adxl345.setup()
    bmp085.setup()
end

function setup()

    -- dock release setup
    dockRelease = 0 -- set status (start with DR closed)
    pwm.setup(DR_PIN, 50, DR_CLOSED_DUTY) -- setup pwm settings (50Hz)
    pwm.start(DR_PIN) -- start sending pwm signal
    pwm.setup(TH_PIN, 50, 50)
    pwm.start(TH_PIN)

    if pcall(i2cSetup) then
        print("i2c setup complete")
    else
        print("i2c unavailable")
        noi2c = 1
        errorF = 1
    end
    
end

function setThrust()
    thrustVal = 50 + (thrustPos / 2)
    pwm.setduty(TH_PIN, thrustVal)
end



function readAccelerometer()
    if (noi2c == 1) then
        accX = 0
        accY = 0
        accZ = 0
        pressure = 0
    else
        accX,accY,accZ = adxl345.read()
        pressure= bmp085.pressure()
    end
    

end

function triggerAbort()
    if(abort == 1) then
        thrustPos = 0
    end
end

function getTemp()
    temp = math.floor((adc.read(0) / 28) * 10 + 0.5) / 10
end
-- -------------------------------------------------------------------------- --
--                                END FUNCTIONS                               --
-- -------------------------------------------------------------------------- --


-- --------------------------- ONE TIME SETUP CODE -------------------------- --



-- Setup docking release
setup()
gpio.mode(8, gpio.OUTPUT) -- setup abort pin
gpio.write(8,gpio.LOW)

--setup function for communicating with atmega

-- -------------------------------- MAIN CODE ------------------------------- --

-- -------------------------------- MAIN CODE ------------------------------- --


function main()
    -- setup thruster
    
    if (start == 1) then
        dockRelease = 1 --unlocked
        thrustPos = 11
        -- check timer
    end

    if (powerCycle == 1) then
        start = 0
        stop = 0
        thrustPos = 0
        abort = 0
        powerCycle = 0
    else
    
    end
    
    if (stop == 1) then
        start = 0
        thrustPos = 0
        
    end

     if (abort == 1) then
        start = 0
        stop = 1
        thrustPos = 0
        
    end
    
    if(restart == 1) then
        start = 0
        stop = 1
        dockRelease = 0 -- locked
        thrustPos = 0
        abort = 0
    end
    
    updateDockRelease()
    setThrust()
    readAccelerometer()
    getTemp()
    triggerAbort()
end


-- ----------------------- OTHER NETWORKING PROCESSES ----------------------- --

--Setup WiFi and other wifi related stuff below here
station_cfg={}
station_cfg.ssid=wifiSsid
station_cfg.pwd=wifiPwd
station_cfg.save=false
wifi.setmode(wifi.STATION, true)
wifi.sta.config(station_cfg)
cfg = {}
cfg.ip = "192.168.137.100"
cfg.netmask = "255.255.255.0"
cfg.gateway = "192.168.137.1"
wifi.sta.setip(cfg)
wifi.sta.autoconnect(1)

-- Connect to wifi and setup the main loop

sys1 = tmr.create()
sys1:alarm(3000, tmr.ALARM_SINGLE, function()
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
            mainTmr:register(100, tmr.ALARM_AUTO, function() main() end)
            if not mainTmr:start() then print("uh oh") end
            wifi.sta.sethostname("LANDER-ESP8266")
        end
    end)
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
    
    receiveDataErrorWrapper() -- use the recieved data to repopulate our status variables
    -- Send data to the server
    conn:send("HTTP/1.1 200 OK\n")
    conn:send("Access-Control-Allow-Origin: * \r\n\n\n")
    conn:send(sendDataErrorWrapper()) -- send our current status variables to the website
  end)
  conn:on("sent",function(conn) conn:close() end)
end)
