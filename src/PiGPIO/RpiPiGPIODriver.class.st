Class {
	#name : #RpiPiGPIODriver,
	#superclass : #PotBoardDriver,
	#instVars : [
		'piGPIO'
	],
	#category : #PiGPIO
}

{ #category : #accessing }
RpiPiGPIODriver class >> driver: aPiGPIOdriver [
	self new driver: aPiGPIOdriver
]

{ #category : #controlling }
RpiPiGPIODriver >> connectToBoard [
	piGPIO version
]

{ #category : #accessing }
RpiPiGPIODriver >> driver: aPiGPIOInstance [
	
	piGPIO := aPiGPIOInstance
]

{ #category : #operations }
RpiPiGPIODriver >> readDigitalValueFrom: aPin [
	^piGPIO digitalRead: aPin
]

{ #category : #operations }
RpiPiGPIODriver >> writeDigitalValue: aBit into: aPin [
	piGPIO digitalWrite: aPin value: aBit
]

{ #category : #operations }
RpiPiGPIODriver >> writePWMValue: anInteger into: aPin [
	piGPIO pin: aPin pwmWrite: anInteger
]
