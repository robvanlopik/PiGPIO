"
see http://abyz.me.uk/rpi/pigpio/sif.html for the PiGPIO socket interface. Command names and numeric values are defined their and always mentioned in the method comments.
"
Class {
	#name : #PiGPIO,
	#superclass : #Object,
	#instVars : [
		'socket',
		'socketLock',
		'ip',
		'port'
	],
	#category : #PiGPIO
}

{ #category : #'instance creation' }
PiGPIO class >> onIP: anIPString port: aPortNumber [
	^self new
		connectOnIP: anIPString port: aPortNumber
		yourself
]

{ #category : #'as yet unclassified' }
PiGPIO >> closeConnection [
	"shutdown the socket"	
			
	socket closeAndDestroy 
]

{ #category : #initialization }
PiGPIO >> connectOnIP: anIPString port: aPortNumber [
	"if the socket cannot be opened, store nil"	
			
	self isConnected ifTrue: [ ^self ].
	socket := Socket newTCP.
	ip := NetNameResolver addressForName: anIPString.
	port := aPortNumber.
	socket connectTo: ip port: port;
		waitForConnectionFor: 10.
	socket isConnected ifFalse: [ socket := nil ].
	socketLock := Mutex new.
		
]

{ #category : #'digital pins' }
PiGPIO >> digitalRead: pinNr [
	"readd the digital pin pinNr	
	READ = 3"	
	^self runCommand: 3 p1: pinNr p2:0
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
			
	| answer |
	socket sendData: (self packedCommand: 17 p1: 0 p2: 0).
	answer := (socket receiveData ) asByteArray.
	^answer unsignedLongAt: 13
]

{ #category : #testing }
PiGPIO >> isConnected [
	^socket notNil
]

{ #category : #'digital pins' }
PiGPIO >> modeOfPin: pinNr [
	"get the mode of pin pinNr. 0 meansoutput, 1 = input ...
		MODEG = 1"
		
	^self runCommand: 1 p1: pinNr p2: 0
]

{ #category : #i2c }
PiGPIO >> openI2C: devId [
	"create a n I2C connection to a device with I2C address devId.
	We use bus 1, (on GPIO2 and GPIO3, because bus 0 is taken by the system;
	 actually, on the oldes Pi's you should use bus 0
	I2CO = 54"	
	
	| h |
	h := self runExtendedCommand: 54 p1: 1 p2: devId bytes: (#(0 0 0 0) asByteArray).
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

{ #category : #pwm }
PiGPIO >> pin: pinNr pwmFrequency: aFrequency [
	"cset the PWM frequency to nearest possible value"
	"PFS = 7"	
			
	^self runCommand: 7 p1: pinNr p2: aFrequency
]

{ #category : #pwm }
PiGPIO >> pin: pinNr pwmRange: range [
	"set the PWM range for the pin
	PRS = 6"	
			
	^self runCommand: 6 p1: pinNr p2: range 
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
			
	^self runCommand: 8 p1: pinNr p2: width
]

{ #category : #pwm }
PiGPIO >> pwmFrequencyOnPin: aPinNr [
	"request PWF frequency of the pin
	PFG = 23"	
			
	^self runCommand: 23 p1: aPinNr p2: 0
]

{ #category : #pwm }
PiGPIO >> pwmRangeOnPin: pinNr [
	"report the pwm range on the pin
	PRG = 22"	
			
	^self runCommand: 22 p1: pinNr p2: 0
]

{ #category : #pwm }
PiGPIO >> pwmRealRangeOnPin: pinNr [
	"set the real PWM range for the pin
	PRRG = 24"	
			
	^self runCommand: 24 p1: pinNr p2: 0 
]

{ #category : #pwm }
PiGPIO >> pwmValueForPin: pinNr [
	"get the value (duty cycle) for pin
	GDC	 = 83"
			
	^self runCommand: 83 p1: pinNr p2: 0
]

{ #category : #utilities }
PiGPIO >> runCommand: cmdNr p1: param1 p2: param2 [
	"run the command nr with mutex control. assert an eventual error else return the result"	
			
	| answer result|
	socketLock critical: 
		[ socket sendData: (self packedCommand: cmdNr p1: param1 p2: param2).
			answer := socket receiveData asByteArray ].
	result := answer signedLongAt: 13.
	self assert: (result >= 0) description: ('error code: ', result printString ) .
	^result
]

{ #category : #utilities }
PiGPIO >> runExtendedCommand: cmdNr p1: param1 p2: param2 bytes: aByteArray [
	"run the command nr with mutex control. assert an eventual error else return the result"	
			
	| answer result|
	socketLock critical: 
		[ socket sendData: (self packedExtendedCommand: cmdNr p1: param1 p2: param2 bytes: aByteArray).
			answer := socket receiveData asByteArray ].
	result := answer signedLongAt: 13.
	self assert: (result >= 0) description: ('error code: ', result printString ) .
	^result
]

{ #category : #servos }
PiGPIO >> servoPulsewidthOnPin: pinNr [
	"get the servo pulse width of the pin
	GPW = 84"
	^self runCommand: 84 p1: pinNr p2: 0
]

{ #category : #accessing }
PiGPIO >> socket [
	^ socket
]

{ #category : #testing }
PiGPIO >> version [ 
	"request the version of the PIGPIO daemon
		PIGPV = 26"
	| answer |
	socket sendData: (self packedCommand: 26 p1: 0 p2: 0).
	answer := (socket receiveData) asByteArray.
	^answer unsignedLongAt: 13
]
