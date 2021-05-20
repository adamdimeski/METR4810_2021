local sda, scl = 2, 1
i2c.setup(0, sda, scl, i2c.SLOW)  -- call i2c.setup() only once
adxl345.setup()


function main()
    local x,y,z = adxl345.read()
    print(string.format("X = %d, Y = %d, Z = %d", x, y, z))

end

mainTmr = tmr.create()
mainTmr:register(100, tmr.ALARM_AUTO, function() main() end)
if not mainTmr:start() then print("uh oh") end
