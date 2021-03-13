wifi.mode(wifi.STATION)
wifi.start()
station_cfg = {}
station_cfg.ssid="COVID-5G"
station_cfg.pwd="1300655506"
station_cfg.auto=true
station_cfg.save=true
wifi.sta.config(station_cfg)

srv=net.createServer(net.TCP)
srv:listen(80,function(connection)
   connection:on ("receive",
    function(sck, req)
      print(req)
      wifi.sta.getmode()
      local response = {"HTTP/1.0 200 OK", "Server: ESP (nodeMCU)", "Content-Length: 1\n", "a"}
      local function sender (sck)
        if #response>0 then sck:send(table.remove(response,1))
        else sck:close()
        end
      end
      sck:on("sent", sender)
      sender(sck)
    end )
  connection:on("sent",function(connection) connection:close() end)
end)
