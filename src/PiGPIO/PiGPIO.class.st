"
see http://abyz.me.uk/rpi/pigpio/sif.html for the PiGPIO socket interface. Command names and numeric values are defined there and always mentioned in the method comments.

inspiration from python code.

Basically there are four types of commmands:
16-bytes command with 16 bytes answer (in last four) - runCommand:  p1:  p2: 
16-bytes command with bigger answer - runCommandReturnBytes: p1: p2:
big command with 16 bytes answer - runExtendedCommand: p1: p2: bytes:
big command with big answer - runExtendedCommandReturnBytes: p1: p2: bytes:

PIGPIO Python uses _pigpio_command_nolock in the case of big answers and implements the lock within each command.

instance creation with IP address and port number (default 8888)
"
Class {
	#name : #PiGPIO,
	#superclass : #Object,
	#instVars : [
		'commandStream',
		'commandLock',
		'ip',
		'port',
		'eventListener'
	],
	#category : #PiGPIO
}

{ #category : #'instance creation' }
PiGPIO class >> onIP: anIPString port: aPortNumber [
	^self new
		connectOnIP: anIPString port: aPortNumber;
		yourself
]

{ #category : #'event processing' }
PiGPIO >> cancelWatchdogOnPin: aPinNumber [
	self setWatchdogOnPin: aPinNumber timeout: 0
]

{ #category : #'initialization-release' }
PiGPIO >> closeConnection [
	"shutdown the socket"	
			
	commandStream close
]

{ #category : #'initialization-release' }
PiGPIO >> connectOnIP: anIPString port: aPortNumber [
	"if the socket cannot be opened, store nil"	
			
	self isConnected ifTrue: [ ^self ].
	
	commandStream := SocketStream openConnectionToHostNamed: anIPString port: aPortNumber.
	commandStream isConnected ifFalse: [ commandStream := nil ].
	commandStream binary.
	commandLock := Mutex new.
	ip := anIPString.
	port := aPortNumber
	
		
]

{ #category : #'digital pins' }
PiGPIO >> debouncePin: pinNr duration: micros [
	"add a glitch filter for the duration of micros microseconds (0 - 300000
	this does not affect read, only pinchanges
	code FG = 97"
	self runCommand: 97 p1: pinNr  p2: micros .
]

{ #category : #'digital pins' }
PiGPIO >> digitalRead: pinNr [
	"readd the digital pin pinNr	
	READ = 3"	
	^(self runCommand: 3 p1: pinNr p2:0) at: 1
]

{ #category : #'digital pins' }
PiGPIO >> digitalWrite: pinNr value: oneOrZero [
	"cset digital output on pin pinNr
	WRITE = 4"
	| data |
	data := 1.
	(oneOrZero = 0) ifTrue: [ data := 0 ].
	self runCommand: 4 p1: pinNr p2: data
]

{ #category : #'event processing' }
PiGPIO >> eventsToWatch: aList [
	"send array with the event numbers to watch for event triggers 
	"
	"command: EVM = 115"
	| handle mask|
	mask := 0.
	aList do: [ :ev | mask := mask bitOr: (1 bitShift: ev) ].
	handle := eventListener handle.
	handle ifNil: [ self error: 'no eventloop running' ].
	eventListener eventsToMonitor: mask.
	self runCommand: 115 p1: handle p2: mask.
]

{ #category : #testing }
PiGPIO >> hwVersion [
	"return the hard version of the board"
	"HWVER = 17"	
			
	^(self runCommand: 17 p1: 0 p2: 0) unsignedLongAt: 1
]

{ #category : #testing }
PiGPIO >> isConnected [
	^commandStream notNil
]

{ #category : #'digital pins' }
PiGPIO >> modeOfPin: pinNr [
	"get the mode of pin pinNr. 0 means input, 1 = output ...
		MODEG = 1"
		
	^(self runCommand: 1 p1: pinNr p2: 0) at: 1
]

{ #category : #i2c }
PiGPIO >> openI2C: devId [
	"create an I2C connection to a device with I2C address devId.
	We use bus 1 on GPIO2 and GPIO3, because bus 0 is taken by the system;
	 actually, on the oldest Pi's you should use bus 0
	I2CO = 54"	
	
	| h |
	h := (self runExtendedCommand: 54 p1: 1 p2: devId bytes: (#(0 0 0 0) asByteArray)) signedLongAt: 1.
	^PiGPIOI2CConnection new piGPIO: self; handle: h; yourself
]

{ #category : #utilities }
PiGPIO >> packedCommand: cmdNr p1: param1 p2: param2 [
	| commandBuffer |
	commandBuffer := ByteArray new: 16.
	commandBuffer  unsignedLongAt: 1 put: cmdNr ;
					unsignedLongAt: 5 put: param1;
					unsignedLongAt: 9 put: param2;
					unsignedLongAt: 13 put: 0.
	^commandBuffer
					
]

{ #category : #utilities }
PiGPIO >> packedExtendedCommand: cmdNr p1: param1 p2: param2 bytes: aByteArray [ 
	"create an extended command stringwith p3 the size of the extent	"
			
	| commandBuffer |
	commandBuffer := ByteArray new: (16 + aByteArray size).
	commandBuffer  unsignedLongAt: 1 put: cmdNr ;
					unsignedLongAt: 5 put: param1;
					unsignedLongAt: 9 put: param2;
					unsignedLongAt: 13 put: (aByteArray size).
	1 to: (aByteArray size)	do: [ :i | commandBuffer at: (i + 16) put: (aByteArray at: i) ]	.
	
	^commandBuffer
	
]

{ #category : #'digital pins' }
PiGPIO >> pin: pinNr mode: modeNr [
	"cset pin pinNr to mode modeNr
	MODES = 0"	
	 self runCommand: 0 p1: pinNr p2: modeNr
]

{ #category : #'digital pins' }
PiGPIO >> pin: aPinNr pullUpDnMode: zeroOneOrTwo [
	"control the pullup pulldown resister when pin is in input mode
	0 = OFF, 1 = DOWN, 2 = UP.
	PUD = 2"
	
	self runCommand: 2 p1: aPinNr p2: zeroOneOrTwo
]

{ #category : #pwm }
PiGPIO >> pin: pinNr pwmFrequency: aFrequency [
	"cset the PWM frequency to nearest possible value"
	"PFS = 7"	
			
	^(self runCommand: 7 p1: pinNr p2: aFrequency) signedLongAt: 1
]

{ #category : #pwm }
PiGPIO >> pin: pinNr pwmRange: range [
	"set the PWM range for the pin
	PRS = 6"	
			
	^(self runCommand: 6 p1: pinNr p2: range ) signedLongAt: 1
]

{ #category : #pwm }
PiGPIO >> pin: pinNr pwmWrite: aNumber [
	"cset the PWM value between 0 and range (see pwmRangeForPin:, default is 255)
	PWM = 5"	
			
	self runCommand: 5 p1: pinNr p2: aNumber
]

{ #category : #servos }
PiGPIO >> pin: pinNr servoPulsewidth: width [
	"set the pulse width in microseconds; frequencyis fixed at 50 Hz.
	SERVO = 8"	
			
	^(self runCommand: 8 p1: pinNr p2: width) signedLongAt: 1
]

{ #category : #'event processing' }
PiGPIO >> pinsToWatch: aList [
	"send array with the pin numbers to watch for level changes"
	"command: NB = 19"
	| handle mask|
	mask := 0.
	aList do: [ :pin | mask := mask bitOr: (1 bitShift: pin) ].
	handle := eventListener handle.
	handle ifNil: [ self error: 'no eventloop running' ].
	eventListener pinsToMonitor: mask.
	self runCommand: 19 p1: handle p2: mask.
]

{ #category : #pwm }
PiGPIO >> pwmFrequencyOnPin: aPinNr [
	"request PWF frequency of the pin
	PFG = 23"	
			
	^(self runCommand: 23 p1: aPinNr p2: 0) signedLongAt: 1
]

{ #category : #pwm }
PiGPIO >> pwmRangeOnPin: pinNr [
	"report the pwm range on the pin
	PRG = 22"	
			
	^(self runCommand: 22 p1: pinNr p2: 0) signedLongAt: 1
]

{ #category : #pwm }
PiGPIO >> pwmRealRangeOnPin: pinNr [
	"set the real PWM range for the pin
	PRRG = 24"	
			
	^(self runCommand: 24 p1: pinNr p2: 0 ) signedLongAt: 1
]

{ #category : #pwm }
PiGPIO >> pwmValueForPin: pinNr [
	"get the value (duty cycle) for pin
	GDC	 = 83"
			
	^(self runCommand: 83 p1: pinNr p2: 0) signedLongAt: 1
]

{ #category : #'digital pins' }
PiGPIO >> readBank1 [
	"return a bitmmap of high pins in bank 1
	BR1 = 10 -- The result is unsigned 32 bits integer, so cannot use #runCommand"
	^self runCommandUnsignedReturn: 10 p1: 0 p2: 0
]

{ #category : #'announce requests' }
PiGPIO >> removeSubscription: aSubscription [
		eventListener announcer removeSubscription: aSubscription 
	
]

{ #category : #utilities }
PiGPIO >> runCommand: cmdNr p1: param1 p2: param2 [
	"run the command nr with mutex control. assert an eventual error else return the result"	
			
	| answer result|
	commandLock critical: 
		[ commandStream nextPutAll: (self packedCommand: cmdNr p1: param1 p2: param2); flush.
			answer := (commandStream next: 16) asByteArray ].
	result := answer signedLongAt: 13.
	self assert: (result >= 0) description: ('error code: ', result printString ) .
	^answer allButFirst: 12
]

{ #category : #utilities }
PiGPIO >> runCommandReturnBytes: cmdNr p1: param1 p2: param2 [
	"run the command nr with mutex control. assert an eventual error else return the *extended* result"	
			
	| answer result|
	commandLock critical: 
		[ commandStream nextPutAll: (self packedCommand: cmdNr p1: param1 p2: param2); flush.
			answer := (commandStream next: 16) asByteArray.
			result := answer signedLongAt: 13.
			self assert: (result >= 0) description: ('error code: ', result printString ) .
			answer := (commandStream next: result) asByteArray].
	^answer  "receiver should test wether the size is correct"
]

{ #category : #utilities }
PiGPIO >> runCommandUnsignedReturn: cmdNr p1: param1 p2: param2 [
	"run the command nr with mutex control. assert an eventual error else return the result as unsigned integer"	
			
	| answer result|
	commandLock critical: 
		[ commandStream nextPutAll: (self packedCommand: cmdNr p1: param1 p2: param2); flush.
			answer := (commandStream next: 16) asByteArray ].
	result := answer unsignedLongAt: 13.
	^result
]

{ #category : #utilities }
PiGPIO >> runExtendedCommand: cmdNr p1: param1 p2: param2 bytes: aByteArray [
	"run the command nr with mutex control. assert an eventual error else return the result"	
			
	| answer result|
	commandLock critical: 
		[ commandStream nextPutAll: (self packedExtendedCommand: cmdNr p1: param1 p2: param2 bytes: aByteArray); flush.
			answer := (commandStream next: 16) asByteArray ].
	result := answer signedLongAt: 13.
	self assert: (result >= 0) description: ('error code: ', result printString ) .
	^answer allButFirst: 12
]

{ #category : #utilities }
PiGPIO >> runExtendedCommandReturnBytes: cmdNr p1: param1 p2: param2 bytes: aByteArray [
	"run the command nr with mutex control. assert an eventual error else return the result"	
			
	| answer result|
	commandLock critical: 
		[ commandStream nextPutAll: (self packedExtendedCommand: cmdNr p1: param1 p2: param2 bytes: aByteArray); flush.
			answer := (commandStream next: 16) asByteArray .
			result := answer signedLongAt: 13.
			self assert: (result >= 0) description: ('error code: ', result printString ) .
			answer := (commandStream next: result) asByteArray ].
	^answer
]

{ #category : #servos }
PiGPIO >> servoPulsewidthOnPin: pinNr [
	"get the servo pulse width of the pin
	GPW = 84"
	^(self runCommand: 84 p1: pinNr p2: 0) signedLongAt: 1
]

{ #category : #'event processing' }
PiGPIO >> setWatchdogOnPin: aPinNumber timeout: duration [
	"set a watchdog on the specified pin; is the pin hasn't changed during the next duration
	 milliseconds a PiGPIOWatchdog announcement will be triggered; 
	to cancel the watchdog set timeout to 0. Timeout maximum is 60000.
	code is WDOG = 9"
	self runCommand: 9 p1: aPinNumber p2: duration
	
]

{ #category : #'event processing' }
PiGPIO >> startEventLoop [
	eventListener := PiGPIOEventLoop new openStreamOn: ip port: port.
	eventListener start.
]

{ #category : #'event processing' }
PiGPIO >> stopEventLoop [
	eventListener stop
]

{ #category : #'event processing' }
PiGPIO >> tickDiffFrom: firstTick to: lastTick [
	"return the difference in ticks, correcting for rollover"
	| diff |
	diff := lastTick - firstTick.
	(diff < 0)ifTrue: [ diff := diff + (1 bitShift: 32) ].
	^diff
]

{ #category : #'event processing' }
PiGPIO >> ticks [
	"return the ticks of thee Pi clock. 32 bits with rollover after 71.6 minutes 
	code TICK = 16, return unsigned long"
		^self runCommandUnsignedReturn: 16 p1: 0 p2: 0
]

{ #category : #misc }
PiGPIO >> trigger: aPinNr length: pulseLength level: oneOrZero [
	"Send a trigger pulse to aPinNrO.  The GPIO is set to
      level for pulseLength microseconds (0-100) and then reset to not level.
	TRIG = 37"
	 
	self runExtendedCommand: 37 p1: aPinNr p2: pulseLength 
				bytes: (ByteArray with: (oneOrZero bitAnd: 1) with: 0 with: 0 with: 0)
]

{ #category : #'event processing' }
PiGPIO >> triggerEvent: eventNumber [
	"trigger an event (nr between 0 and 31). Only effective when this 
	same event is also being watched, #eventsToWatch
	code EVT = 116"
	self runCommand: 116 p1: eventNumber  p2: 0.
]

{ #category : #testing }
PiGPIO >> version [ 
	"request the version of the PIGPIO daemon
		PIGPV = 26"
	^(self runCommand: 26 p1: 0 p2: 0) unsignedLongAt: 1
]

{ #category : #'announce requests' }
PiGPIO >> when: anEvent do: aBlock [
	eventListener announcer when: anEvent do: aBlock
]
