local w = {}

w.wifiSsid = "WiFi-1F14"
w.wifiPwd = "24911917"

w.callbackOn = nil
w.callbackOff = nil
local outpin=16
local state = false
w.tmr = tmr.create()
function w.registerCallbackOn(f)
  w.callbackOn = f
end
function init()
  
  gpio.write(outpin,1)  -- LED is pulled so HIGH = off
  blinkOFF()
  w.pinAdcX = 6
  
  
  
  -- adc.setwidth(adc.ADC1, 9)  -- read 9 bit on ADC
  adc.setwidth(adc.ADC1, 12)  -- read 12 bit on ADC
  adc.setup(adc.ADC1, w.pinAdcX, adc.ATTEN_11db    )
  
  
  w.tmr:alarm(250, tmr.ALARM_AUTO, function()
    w.readX()
    -- m.readY()
    -- m.readX()
  end)
  
  w.isInitted = true
end

w.lastX = 0
function w.readX()
  local val = adc.read(adc.ADC1, w.pinAdcX)
  if w.lastX == val then return end
  w.lastX = val
 
  return val
  
end


function togLED()
  if state==false then gpio.write(outpin,1)
  else                 gpio.write(outpin,0) end
  state = not state;
end
function blkinkON()
if mytimer~=nil then return end -- Timer already on.
mytimer = tmr.create()
mytimer:alarm(200, tmr.ALARM_AUTO, function()  togLED() end)
end

function blinkOFF()
  if mytimer==nil then return end -- Timer already off.
  mytimer:unregister()  mytimer=nil
end


function w.registerCallbackOff(f)
  w.callbackOff = f
end

function w.start()

  wifi.sta.on("got_ip", function(ev, info)
    print("NodeMCU IP config:", info.ip, "netmask", info.netmask, "gw", info.gw)
  
    print('You now have a webserver running at: http://' .. info.ip)
    print("Go visit it and see you get a nice callback to do stuff with like control GPIO ports from the web.")
  end)
end
  --unregister callback
  -- wifi.sta.on("got_ip", nil)
  
  -- set as station
  wifi.mode(1)
  -- start wifi
  wifi.start()
  val = w.readX()
  print("X"..val)
  --connect to Access Point (DO save config to flash)
  station_cfg={}
  station_cfg.ssid=w.wifiSsid
  station_cfg.pwd=w.wifiPwd
  wifi.sta.config(station_cfg, true)
  print("Saved wifi name/password")
  
srv = net.createServer(net.TCP,1)
init()
  
  srv:listen(80, function(conn)
    conn:on("receive",function(conn,payload)
    
    print(payload)  -- View the received data,
    
    function controlLED()
      control = string.sub(payload,fnd[2]+1) -- Data is at end already.
      if control == "launch shuttle"       then gpio.write(outpin,1);  blinkOFF() return end
      if control == "Backup arrestor"      then gpio.write(outpin,0); blinkOFF() return end
      
    end

    --get control data from payload
    fnd = {string.find(payload,"ledbi=")}
    if #fnd ~= 0 then controlLED() end -- Is there data in payload? - Take action if so.

    conn:send('<!DOCTYPE HTML>\n')
    conn:send('<html>\n')
    conn:send('<head><meta http-equiv="content-type" content="text/html; charset=UTF-8">\n')
    -- Scale the viewport to fit the device.
    conn:send('<meta name="viewport" content="width=device-width, initial-scale=1">')
    -- Titlem
    conn:send('<title>ESP8266 Wifi LED Control</title>\n')
    -- CSS style definition for submit buttons
    conn:send('<style>\n')
    conn:send('input[type="submit"] {\n')
    conn:send('color:#050; width:140px; padding:10px;\n')
    conn:send('font: bold 84% "trebuchet ms",helvetica,sans-serif;\n')
    conn:send('background-color:lightgreen;\n')
    conn:send('border:1px solid; border-radius: 12px;\n')
    conn:send('transition-duration: 0.4s;\n')
    conn:send('}\n')
    conn:send('input[type="submit"]:hover {\n')
    conn:send('background-color:lightblue;\n')
    conn:send('color: white;\n')
    conn:send('}')
    conn:send('</style></head>\n')
    -- HTML body Page content.
    conn:send('<body>')
    conn:send('<h1>Shuttle Control Panel<br>release and arrest system</h1>\n')
    
    -- HTML Form (POST type) and buttons.
    conn:send('<form action="" method="POST">\n')
    conn:send('<input type="submit" name="ledbi" value="launch shuttle" > Turn Built in LED on<br><br>\n')
    conn:send('<input type="submit" name="ledbi" value="Backup arrestor"> Turn Built in LED off<br><br>\n')
    
    conn:send('<11>sensor value<br>' .. adc.read(adc.ADC1, w.pinAdcX).. '</p1>\n')
    conn:send('</body></html>\n')
    conn:on("sent",function(conn) conn:close() end)
    end)
end)


return w
