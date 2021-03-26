wifi.mode(wifi.STATION)
wifi.start()
station_cfg = {}
station_cfg.ssid="COVID-5G"
station_cfg.pwd="1300655506"
station_cfg.auto=true
station_cfg.save=true
wifi.sta.config(station_cfg)

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive",function(conn,payload)
    print(payload)
  
    conn:send("HTTP/1.1 200 OK\n")
    conn:send("\r\n\n\n")
    conn:send("Whoomp there it is") 
  end)
  conn:on("sent",function(conn) conn:close() end)
end)
