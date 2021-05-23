local sda, scl = 1, 2
i2c.setup(0, sda, scl, i2c.SLOW)

bme280.setup(0,1)