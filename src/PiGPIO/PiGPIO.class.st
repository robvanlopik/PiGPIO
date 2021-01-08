"
see http://abyz.me.uk/rpi/pigpio/sif.html for the PiGPIO socket interface. Command names and numeric values are defined their and always mentioned in the method comments.

inspiration from python code.

Basically there are four types of commmands:
16-bytes command with 16 bytes answer (in last four) - runCommand:  p1:  p2: 
16-bytes command with bigger answer - runCommandReturnBytes: p1: p2:
big command with 16 bytes answer - runExtendedCommand: p1: p2: bytes:
big command with big answer - runExtendedCommandReturnBytes: p1: p2: bytes:

PIGPIO Python uses _pigpio_command_nolock in the case of big answers and implements the lock within each command.
"
Class {
	#name : #PiGPIO,
	#superclass : #Object,
	#instVars : [
		'socket',
		'commandStream',
		'commandLock',
		'socketLock',
		'ip',
		'port'
	],
	#category : #PiGPIO
}

{ #category : #'instance creation' }
PiGPIO class >> onIP: anIPString port: aPortNumber [
	^self new
		connectOnIP: anIPString port: aPortNumber;
		yourself
]

{ #category : #'as yet unclassified' }
PiGPIO >> closeConnection [
	"shutdown the socket"	
			
	commandStream close
]

{ #category : #initialization }
PiGPIO >> connectOnIP: anIPString port: aPortNumber [
	"if the socket cannot be opened, store nil"	
			
	self isConnected ifTrue: [ ^self ].
	"socket := Socket newTCP.
	ip := NetNameResolver addressForName: anIPString.
	port := aPortNumber.
	socket connectTo: ip port: port;
		waitForConnectionFor: 10.
	socket isConnected ifFalse: [ socket := nil ].
	socketLock := Mutex new."
	commandStream := SocketStream openConnectionToHostNamed: anIPString port: aPortNumber.
	commandStream isConnected ifFalse: [ commandStream := nil ].
	commandStream binary.
	commandLock := Mutex new.
	
		
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

{ #category : #testing }
PiGPIO >> hwVersion [
	"return the hard version of the board"
	"HWVER = 17"	
			
	^(self runCommand: 17 p1: 0 p2: 0) unsignedLongAt: 1
]

{ #category : #testing }
PiGPIO >> isConnected [
	^socket notNil
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

{ #category : #misc }
PiGPIO >> trigger: aPinNr length: pulseLength level: oneOrZero [
	"Send a trigger pulse to aPinNrO.  The GPIO is set to
      level for pulseLength microseconds (0-100) and then reset to not level.
	TRIG = 37"
	 
	self runExtendedCommand: 37 p1: aPinNr p2: pulseLength 
				bytes: (ByteArray with: (oneOrZero bitAnd: 1) with: 0 with: 0 with: 0)
]

{ #category : #testing }
PiGPIO >> version [ 
	"request the version of the PIGPIO daemon
		PIGPV = 26"
	^(self runCommand: 26 p1: 0 p2: 0) unsignedLongAt: 1
]
