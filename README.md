# PiGPIO
### Pharo interface to PiGPIO library for Raspberry Pi

PiGPIO (http://abyz.me.uk/rpi/pigpio/index.html) is used to control the GPIO pins on a Raspberry Pi. This Pharo interface uses the socket interface to de pigpiod daemon. This has three advantages:
- as the daemon runs as su, no privilege is needed for the Pharo code.
- the Pharo image can be run on the Pi using the local daemon or remote overr TCP/IP.
- (last but not least) it is simple to implement

To use it, you must first start the daemon on the Pi:
`$ sudo pigpiod`

An instance of the driver is created with:
`myPiController := PiGPIO onPort: '192.168.1.55' port: 8888`

The IP address is an example; use 127.0.0.1 when running on the Rapberry Pi itself. . The default port number is 8888.
Now you can do things like:
 ```
 myPiController version.
 myPiController pin: 5 value: 1.
 x := myPiController digitalRead: 2.
 myPiController pin: 14 pwmWrite: 128.
```
#### I2C communication:
```
i2cConnectionn := myPiController openI2C: 16r68. "the I2C address of the device e.g. the DS1307 real time clock"
month := i2cConnection read8BitsAt: 5. "register 5, in this example the month in BCD format"
```

There is also a PotBoardDriver for Pharo-IOT (https://github.com/pharo-iot/PharoThings)
Now the incantation is:
```
myRemotePi := RpiBoard3B driver: (RpiPiGPIODriver onIP: '192.168.1.55' port: 8888)
```

Not all functions of the pigpiod daemon are implemented, but some will be added in the near future
