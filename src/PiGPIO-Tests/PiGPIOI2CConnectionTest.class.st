Class {
	#name : #PiGPIOI2CConnectionTest,
	#superclass : #TestCase,
	#instVars : [
		'i2cConnection'
	],
	#category : #'PiGPIO-Tests'
}

{ #category : #running }
PiGPIOI2CConnectionTest >> setUp [
	super setUp.
	i2cConnection := PiGPIOI2CConnection new piGPIO: MockObject  new.
	i2cConnection handle: 2.
	"Put here a common initialization logic for tests" 
]

{ #category : #tests }
PiGPIOI2CConnectionTest >> testWrite16BitsAt [

(i2cConnection piGPIO) on: #runExtendedCommand:p1:p2:bytes:
	withArguments: {64 . 2 . 10 . #( 16r01 16rab 0 0) asByteArray}.

	i2cConnection write16BitsAt: 10 data: 16rab01.
	self verify: (i2cConnection piGPIO)
]

{ #category : #tests }
PiGPIOI2CConnectionTest >> testWrite8BitsAt [

(i2cConnection piGPIO) on: #runExtendedCommand:p1:p2:bytes:
	withArguments: {62 . 2 . 10 . #(50 0 0 0) asByteArray}.

	i2cConnection write8BitsAt: 10 data: 50.
	self verify: (i2cConnection piGPIO)
]

{ #category : #tests }
PiGPIOI2CConnectionTest >> testWriteByte [

(i2cConnection piGPIO) on: #runCommand:p1:p2:
	withArguments: {60 . 2 . 50}.

	i2cConnection writeByte: 50.
	self verify: (i2cConnection piGPIO)
]

{ #category : #tests }
PiGPIOI2CConnectionTest >> testWriteByteAt [

(i2cConnection piGPIO) on: #runExtendedCommand:p1:p2:bytes:
	withArguments: {62 . 2 . 10 . #(50 0 0 0) asByteArray}.

	i2cConnection writeByteAt: 10 data: 50.
	self verify: (i2cConnection piGPIO)
]
