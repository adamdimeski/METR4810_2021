------------------------------- GLOBAL VARIABLES -------------------------------
-- Wifi settings
wifiSsid = "COVID-5G"
wifiPwd = "1300655506"

-- Pin mappings
DR_PIN = 5
DR_OPEN_DUTY = 69
DR_CLOSED_DUTY = 98

-- Thruster
TH_PIN = 6
TH_START_DUTY = 50
-- I2C Pins
sda, scl = 1, 2

------------------------------- NETWORKING VARIABLES -------------------------------
-- Variables is for things that will change throughout execution

dockRelease = 0 -- 0 for latched, 1 for unlatched
abort = 0 -- 0 for normal operation ,1 for abort
drServoPos = 0 -- Servo position for dock release
thrustPos = 0 -- thrust percentage of EDF
start = 0 -- start of mission, activates release from dock and activation of systems. 
-- 1 for start of mission
stop = 0 -- stops a mission and sets the start value to 0. 1 for mission stop
restart = 0 -- resets all the values and readies the lander for another mission. 1 for reset
powerCycle = 0 -- 0 for normal state, 1 for restarting the sensor, microcontroller circuits
accX = 0 -- accelerometer reading for x-plane
accY = 0 -- accelerometer reading for y-plane
accZ = 0 -- accelerometer reading for z-plane
temp = 0 -- temperature reading
pressure = 0 -- barometer reading
status={} -- table the contains received data from ground control
noi2c = 0 -- 0 for operation, 1 for non-operation. Used for handling errors
errorF = 0 -- error flag. Is raised to 1 when an error has been handled in th system. 
-- Notifies ground control

------------------------------- FUNCTIONS -------------------------------
-- unpacks the received http request and puts the values into global variables
function receiveData()

    dockRelease = tonumber(status.dockRelease)
    abort = tonumber(status.abort)
    drServoPos = tonumber(status.drServoPos)
    thrustPos = tonumber(status.thrustPos)
    start = tonumber(status.start)
    stop = tonumber(status.stop)
    restart = tonumber(status.restart)
    powerCycle = tonumber(status.powerCycle)
end

-- A wrapper function handles errors occuring with receiveData function
-- Mainly handles nil values that may occur due to errors with http client
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

-- assembles a csv string containing lander data to be sent to the client
function sendData()

    sendStr = "";
    sendStr = sendStr.. dockRelease..",";
    sendStr = sendStr.. thrustPos.. ",";
    sendStr = sendStr.. accX.. ",";
    sendStr = sendStr.. accY.. ",";
    sendStr = sendStr.. accZ.. ",";
    sendStr = sendStr.. pressure.. ",";
    sendStr = sendStr.. temp.. ",";
    sendStr = sendStr.. errorF;

    return sendStr
end

-- A wrapper function handles errors occuring with sendData function
-- Mainly handles nil values that may occur due to errors with http client
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


-------------------------------- Lander Functions -------------------------------


function updateDockRelease()
    -- Updates the dock release mechanism open/closed based on our desired 
    -- dockRelease status

    if(dockRelease == 0) then
        -- Set the dock release to the closed position
        pwm.setduty(DR_PIN,DR_CLOSED_DUTY) --DR_OPEN_DUTY
    else
        -- Set the dock release to the open position
        pwm.setduty(DR_PIN,DR_OPEN_DUTY)
    end
end

-- Setup of I2C communication for sensor packacges
function i2cSetup()
    i2c.setup(0, sda, scl, i2c.SLOW)  
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

    -- error handling if i2c cannot be setup
    if pcall(i2cSetup) then
        print("i2c setup complete")
    else
        print("i2c unavailable")
        noi2c = 1 -- flag for lander to substitude dummy values if 
        --sensor values cannot be read
        errorF = 1 -- flags an error
    end
    
end

-- sets the pwm value corresponding the thrust %
function setThrust()
    if (thrustPos > 25) then
        thrustVal = 50 + (25 / 2)
    else
        thrustVal = 50 + (thrustPos / 2)
    end
    
    pwm.setduty(TH_PIN, thrustVal)
end


-- reads data from the accelerometer and barometer
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

-- Gets tge temperature from the thermistor using an ADC read
function getTemp()
    temp = math.floor((adc.read(0) / 28) * 10 + 0.5) / 10
end
-------------------------------- Setup -------------------------------


setup() -- calls the setup function
gpio.mode(8, gpio.OUTPUT) -- setup abort pin
gpio.write(8,gpio.LOW)

----------------------------------- MAIN CODE ------------------------------- --

function main()

    -- if statements change the status of lander depending on mission parameters
    if (start == 1) then
        dockRelease = 1 --unlocked
        -- check timer
    end

    if (powerCycle == 1) then
        start = 0
        stop = 0
        thrustPos = 0
        abort = 0
        powerCycle = 0
        gpio.write(8,gpio.HIGH)
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

    -- calls functions to update status of lander
    updateDockRelease()
    setThrust()
    readAccelerometer()
    getTemp()
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
cfg.ip = "192.168.137.100" -- a static IP address is used
cfg.netmask = "255.255.255.0"
cfg.gateway = "192.168.137.1" 
wifi.sta.setip(cfg)
wifi.sta.autoconnect(1)

-- Connect to wifi and setup the main loop

--sys1 is a blocking timer used to delay the start of hte program to delete 
--init.lua without a system crash
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
    -- unpacking the data into the table
    for k, v in string.gmatch( string_payload, "(%w+)=(%w+)" ) do
        status[k] = v
    end
    
    receiveDataErrorWrapper() -- use the recieved data to 
    --repopulate our status variables
    
    -- Send data to the server
    conn:send("HTTP/1.1 200 OK\n")
    conn:send("Access-Control-Allow-Origin: * \r\n\n\n")
    conn:send(sendDataErrorWrapper()) -- send our current status variables to the website
  end)
  conn:on("sent",function(conn) conn:close() end)
end)
