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

{ #category : #'as yet unclassified' }
PiGPIO >> digitalwrite: pinNr value: oneOrZero [
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

{ #category : #'as yet unclassified' }
PiGPIO >> modeOfPin: pinNr [
	"get the mode of pin pinNr. 0 meansoutput, 1 = input ...
		MODEG = 1"
		
	^self runCommand: 1 p1: pinNr p2: 0
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

{ #category : #'digital pins' }
PiGPIO >> pin: pinNr mode: modeNr [
	"cset pin pinNr to mode modeNr
	MODES = 0"	
	 self runCommand: 0 p1: pinNr p2: modeNr
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
