"
A PiGPIOI2CConnection is created on a PiGPIO for each I2C address.
"
Class {
	#name : #PiGPIOI2CConnection,
	#superclass : #Object,
	#instVars : [
		'piGPIO',
		'handle'
	],
	#category : #PiGPIO
}

{ #category : #'initialize-release' }
PiGPIOI2CConnection >> close [
	"close the I2C connection
	I2CC = 55"
	
	piGPIO runCommand: 55 p1: handle p2: 0.
]

{ #category : #accessing }
PiGPIOI2CConnection >> handle [
	^ handle
]

{ #category : #accessing }
PiGPIOI2CConnection >> handle: anObject [
	handle := anObject
]

{ #category : #accessing }
PiGPIOI2CConnection >> piGPIO [
	^ piGPIO
]

{ #category : #accessing }
PiGPIOI2CConnection >> piGPIO: anObject [
	piGPIO := anObject
]

{ #category : #accessing }
PiGPIOI2CConnection >> read16BitsAt: register [
	"Read a word (2 bytes) at a register; returns a byte as lowest part of an integer
	I2CRW = 63"
	^(self piGPIO runCommand: 63 p1: handle p2: register) unsignedLongAt: 1
]

{ #category : #accessing }
PiGPIOI2CConnection >> read8BitsArray: blockSize startingAt: reg [
	"only used for compatibility with wiringPi"
	^self readDataBlock: blockSize at: reg
]

{ #category : #accessing }
PiGPIOI2CConnection >> read8BitsAt: register [
	"Read a byte at a register; returns a byte as lowest part of an integer
	I2CRB = 61"
	^(self piGPIO runCommand: 61 p1: handle p2: register) unsignedLongAt: 1
]

{ #category : #accessing }
PiGPIOI2CConnection >> readDataBlock: count at: reg [ 
	"read count bytes of data starting at register reg"
	"I2CRI = 67"
	| result payLoad |
	payLoad := ByteArray new: 4.
	payLoad unsignedLongAt: 1 put: count.
	result := self piGPIO runExtendedCommandReturnBytes: 67 p1: handle p2: reg bytes: payLoad.
	self assert: ((result size) = count) description: 'incorrect byte count from I2CRI'.
	^result 
]

{ #category : #accessing }
PiGPIOI2CConnection >> write16BitsAt: register data: aWord [
	"Read a word (2 bytes) at a register; returns a byte as lowest part of an integer
	I2CRW = 63"
	^self piGPIO runExtendedCommand: 63 p1: handle p2: register 
			bytes: (ByteArray with: (aWord \\ 256) with: (aWord // 256) with: 0 with: 0 )
]

{ #category : #accessing }
PiGPIOI2CConnection >> write8BitsAt: register data: aByte [
	"Read a byte at a register; returns a byte as lowest part of an integer
	I2CRB = 62"
	^self piGPIO runExtendedCommand: 62 p1: handle p2: register 
				bytes: (ByteArray with: (aByte bitAnd: 16rFF) with: 0 with: 0 with: 0)
]
