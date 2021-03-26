
status={}

function update_status()
    val1 = tonumber(status["val1"])
    val2 = tonumber(status["val2"])
    val3 = tonumber(status["val3"])
    etc = tonumber(status["etc"])   
end



--Setup WiFi
station_cfg={}
station_cfg.ssid="COVID-5G"
station_cfg.pwd="1300655506"
station_cfg.auto=true
station_cfg.save=true
wifi.sta.config(station_cfg)


sys = tmr.create()
sys:alarm(1000, tmr.ALARM_SEMI, function() 
    if wifi.sta.getip() == nil then 
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
    for k, v in string.gmatch( string_payload, "(%w+)=(%w+)" ) do
        status[k] = v
    end
    print(payload)
    update_status()
    
    conn:send("HTTP/1.1 200 OK\n")
    conn:send("\r\n\n\n")
  end)
  conn:on("sent",function(conn) conn:close() end)
end)
