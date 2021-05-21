local sda, scl = 1, 2
i2c.setup(0, sda, scl, i2c.SLOW)
bmp085.setup()
local t = bmp085.pressure()
print(string.format("Temperature: %s.%s degrees C", t / 10, t % 10))