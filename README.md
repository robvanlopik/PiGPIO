# PiGPIO
### Pharo interface to PiGPIO library for Raspberry Pi

PiGPIO (http://abyz.me.uk/rpi/pigpio/index.html) is used to control the GPIO pins on a Raspberry Pi. This Pharo interface uses the socket interface to the pigpiod daemon. This has four advantages:
- as the daemon runs as su, no privilege is needed for the Pharo code.
- it allows PWM and servo on all pins.
- the Pharo image can be run on the Pi using the local daemon or remote over TCP/IP.
- (last but not least) it is simple to implement

To use it, you must first start the daemon on the Pi:
`$ sudo pigpiod`

An instance of the driver is created with:
`myPiController := PiGPIO onIP: '192.168.1.55' port: 8888`

The IP address is an example; use 127.0.0.1 when running on the Rapberry Pi itself. . The default port number is 8888.
Now you can do things like:
 ```smalltalk
 myPiController version.
 myPiController pin: 5 value: 1.
 x := myPiController digitalRead: 2.
 myPiController pin: 14 pwmWrite: 128. "range default 0 - 255"
 myPiController pin: 15 servoPulseWidth: 1500. "in microseconds"
```
#### I2C communication:
```
i2cConnectionn := myPiController openI2C: 16r68. "the I2C address of the device e.g. the DS1307 real time clock"
month := i2cConnection read8BitsAt: 5. "register 5, in this example the month in BCD format"
```



#### Announcements

Callbacks have been implemented using pharo's announcement framework. This feature is not enabled by default. It must be started with:

```myPiController startEventLoop```

To get notified of level changes:

```smalltalk
myPiController pinsToWatch: #(12 13). "list of gpio's to monitor"
on: PiGPIOPinChange do: [ :event | .... ].
```
```PiGPIOPinChange``` has accessors ```#pinNr, #newLevel, #tick```. The latter represents the internal clock of the pigpiod daemon, with an accuracy of some microseconds.
### Miscellaneous
Load with:
```smalltalk
Metacello new 
	baseline: 'PiGPIO';
	repository: 'github://robvanlopik/PiGPIO';
	load .
 ```

