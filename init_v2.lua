--[[
  init_v2.lua

  Sets up wifi connection and then runs main.lua.
    
  This lua file will run automatically when the ESP is reset.
  Based on tutorial from: https://learn.adafruit.com/diy-esp8266-home-security-with-lua-and-mqtt/programming-the-esp8266-with-lua.
]]

-- ---------------------------- GLOBAL VARIABLES ---------------------------- --

SSID    = "OPPO Reno 10x Zoom" -- Wifi network name
APPWD   = "Martindb9" -- wifi network password
CMDFILE = "ping.lua"   -- File that is executed after connection
 
wifiTrys     = 15     -- Counter of trys to connect to wifi
NUMWIFITRYS  = 200    -- Maximum number of WIFI Testings while waiting for connection

-- -------------------------------- FUNCTIONS ------------------------------- --

function launch()
  --[[ 
    Launches stuff?
   ]]
  print("Connected to WIFI!")
  print("IP Address: " .. wifi.sta.getip())
  -- Call our command file. Note: if you foul this up you'll brick the device!
  dofile("main_v2.lua")
  makeConn()
end
 
function checkWIFI()
  --[[ 
    This function does ...
   ]]

  if ( wifiTrys > NUMWIFITRYS ) then
    print("Sorry. Not able to connect")
  else
    ipAddr = wifi.sta.getip()
    if ( ( ipAddr ~= nil ) and  ( ipAddr ~= "0.0.0.0" ) )then
      tmr.alarm( 1 , 500 , 0 , launch )
    else
      -- Reset alarm again
      tmr.alarm( 0 , 2500 , 0 , checkWIFI)
      print("Checking WIFI..." .. wifiTrys)
      wifiTrys = wifiTrys + 1
    end 
  end 
end


-- -------------------------------- MAIN LOOP ------------------------------- --

print("-- Starting up! ")
 
-- Lets see if we are already connected by getting the IP
ipAddr = wifi.sta.getip()
if ( ( ipAddr == nil ) or  ( ipAddr == "0.0.0.0" ) ) then
  -- We aren't connected, so let's connect
  print("Configuring WIFI....")
  wifi.setmode( wifi.STATION )
  wifi.sta.config( SSID , APPWD)
  print("Waiting for connection")
  tmr.alarm( 0 , 2500 , 0 , checkWIFI )
else
  -- We are already connected, so just run the launch code.
  launch()
end