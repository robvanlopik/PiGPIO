Class {
	#name : #RpiPiGPIODriver,
	#superclass : #PotBoardDriver,
	#instVars : [
		'driver'
	],
	#category : #PiGPIO
}

{ #category : #accessing }
RpiPiGPIODriver >> driver: aPiGPIOInstance [
	
	driver := aPiGPIOInstance
]

{ #category : #operations }
RpiPiGPIODriver >> readDigitalValueFrom: aPin [
	^driver digitalRead: aPin
]

{ #category : #operations }
RpiPiGPIODriver >> writeDigitalValue: aBit into: aPin [
	driver digitalWrite: aPin value: aBit
]

{ #category : #operations }
RpiPiGPIODriver >> writePWMValue: anInteger into: aPin [
	driver pin: aPin pwmWrite: anInteger
]
