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

{ #category : #accessing }
PiGPIOI2CConnection >> blockProcessCallAt: register data: data [
	"	Writes data bytes to the specified register of the device
      associated with handle and reads a device specified number
      of bytes of data in return.
	I2CPK = 70"

	^(self piGPIO runExtendedCommandReturnBytes: 70 p1: handle p2: register bytes: data) 
]

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
PiGPIOI2CConnection >> processCallAt: register data: aWord [
	"Writes 16 bits of data to the specified register of the device
      associated with handle and reads 16 bits of data in return"
	"I2CPC = 69 "
	| payLoad |
	payLoad := ByteArray new with: (aWord \\ 256) with: (aWord // 256) with: 0 with: 0.
	^(self piGPIO runExtendedCommand: 69 p1: handle p2: register bytes: payLoad) unsignedLongAt: 1
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

{ #category : #'reading-primitive data' }
PiGPIOI2CConnection >> readByte [
	"read a single byte, directly without register
	I2CRS = 59 - 16r3B - returns a number, not a byte"
	^(self piGPIO runCommand: 59 p1: handle p2: 0) unsignedLongAt: 1
]

{ #category : #'reading-primitive data' }
PiGPIOI2CConnection >> readByteAt: register [
	"read a single byte, at register
	I2CRB = 61 - 16r3B - returns a number, not a byte"
	^(self piGPIO runCommand: 61 p1: handle p2: register) unsignedLongAt: 1
]

{ #category : #accessing }
PiGPIOI2CConnection >> readDataBlock: count at: reg [ 
	"read count bytes of data starting at register reg. Python i2c_read_i2c_block_data()"
	"I2CRI = 67"
	| result payLoad |
	payLoad := ByteArray new: 4.
	payLoad unsignedLongAt: 1 put: count.
	result := self piGPIO runExtendedCommandReturnBytes: 67 p1: handle p2: reg bytes: payLoad.
	self assert: ((result size) = count) description: 'incorrect byte count returned from I2CRI'.
	^result 
]

{ #category : #accessing }
PiGPIOI2CConnection >> readDataBlockAt: reg [ 
	"read  bytes of data starting at register reg. The device determines how many bytes are returned
	in Python i2c_read_block_data"
	"I2CRK = 65 -- returns a byte array"
	| result  |
	
	result := self piGPIO runCommandReturnBytes: 65 p1: handle p2: reg.
	^result 
]

{ #category : #'as yet unclassified' }
PiGPIOI2CConnection >> readDevice: count [ 
	"Returns count bytes read from the raw device
	I2CRD = 56"
	| result |
	
	result := self piGPIO runCommandReturnBytes: 56 p1: handle p2: count .
	self assert: ((result size) = count) description: 'incorrect byte count returned from I2CRD'.
	^result 
]

{ #category : #'reading-primitive data' }
PiGPIOI2CConnection >> readWordAt: register [
	"read a single word at register
	I2CRW = 63 - 16r3B - returns a number, not a byte"
	^(self piGPIO runCommand: 63 p1: handle p2: register) unsignedShortAt: 1
]

{ #category : #'reading-primitive data' }
PiGPIOI2CConnection >> readWordBigEndianAt: register [
	"read a single word at register
	I2CRW = 63 - 16r3B - returns a number, not a byte"
	^(self piGPIO runCommand: 63 p1: handle p2: register) 
									unsignedShortAt: 1 bigEndian: true
]

{ #category : #accessing }
PiGPIOI2CConnection >> write16BitsAt: register data: aWord [
	"WWrited a word (2 bytes) at a register; from low to high
	I2CWW = 64"
	^self piGPIO runExtendedCommand: 64 p1: handle p2: register 
			bytes: (ByteArray with: (aWord \\ 256) with: (aWord // 256) with: 0 with: 0 )
]

{ #category : #accessing }
PiGPIOI2CConnection >> write8BitsAt: register data: aByte [
	"write a byte at a register
	I2CWB = 62"
	^self piGPIO runExtendedCommand: 62 p1: handle p2: register 
				bytes: (ByteArray with: (aByte bitAnd: 16rFF) with: 0 with: 0 with: 0)
]

{ #category : #accessing }
PiGPIOI2CConnection >> writeByte: aByte [
	"write a byte without  a register
	I2CWS = 60"
	^self piGPIO runCommand: 62 p1: handle p2: aByte
			
]

{ #category : #accessing }
PiGPIOI2CConnection >> writeByteAt: register data: aByte [
	"write a byte at a register
	I2CWB = 62"
	^self piGPIO runExtendedCommand: 62 p1: handle p2: register 
				bytes: (ByteArray with: (aByte bitAnd: 16rFF) with: 0 with: 0 with: 0)
]

{ #category : #writing }
PiGPIOI2CConnection >> writeDataBlock: aByteArray at: aRegister [
	"write a aByteArray to register with count between reg and data on bus
	I2CWK = 66"
	
	self piGPIO runExtendedCommand: 66 p1: handle p2: aRegister bytes: aByteArray
]

{ #category : #writing }
PiGPIOI2CConnection >> writeDataBlockNoCount: aByteArray at: aRegister [
	"write a aByteArray to register, data directly follows register. Python i2c_write_i2c_block_data()
	I2CWI = 68"
	
	self piGPIO runExtendedCommand: 68 p1: handle p2: aRegister bytes: aByteArray
]

{ #category : #writing }
PiGPIOI2CConnection >> writeDevice: data [
	"Writes the data bytes to the raw device
	I2CWD = 57"
	self piGPIO runExtendedCommand: 57 p1: handle p2: 0 bytes: data
]

{ #category : #accessing }
PiGPIOI2CConnection >> writeWordAt: register data: aWord [
	"WWrited a word (2 bytes) at a register; from low to high
	I2CWW = 64"
	^self piGPIO runExtendedCommand: 64 p1: handle p2: register 
			bytes: (ByteArray with: (aWord \\ 256) with: (aWord // 256) with: 0 with: 0 )
]

{ #category : #accessing }
PiGPIOI2CConnection >> writeWordBigEndianAt: register data: aWord [
	"WWrited a word (2 bytes) at a register; from low to high
	I2CWW = 64"
	^self piGPIO runExtendedCommand: 64 p1: handle p2: register 
			bytes: (ByteArray with: (aWord // 256) with: (aWord \\ 256) with: 0 with: 0 )
]
