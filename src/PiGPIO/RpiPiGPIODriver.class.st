Class {
	#name : #RpiPiGPIODriver,
	#superclass : #PotBoardDriver,
	#instVars : [
		'piGPIO',
		'ip',
		'port'
	],
	#category : #PiGPIO
}

{ #category : #accessing }
RpiPiGPIODriver class >> driver: aPiGPIOdriver [
	self new driver: aPiGPIOdriver
]

{ #category : #'instance creation' }
RpiPiGPIODriver class >> onIP: anIPAddress port: aPortNumber [
	^self new 
		ip: anIPAddress;
		port: aPortNumber
]

{ #category : #controlling }
RpiPiGPIODriver >> connectToBoard [
	piGPIO := PiGPIO onIP: ip port: port
]

{ #category : #accessing }
RpiPiGPIODriver >> driver: aPiGPIOInstance [
	
	piGPIO := aPiGPIOInstance
]

{ #category : #accessing }
RpiPiGPIODriver >> ip [
	^ ip
]

{ #category : #accessing }
RpiPiGPIODriver >> ip: anObject [
	ip := anObject
]

{ #category : #accessing }
RpiPiGPIODriver >> piGPIO [
	^ piGPIO
]

{ #category : #accessing }
RpiPiGPIODriver >> port [
	^ port
]

{ #category : #accessing }
RpiPiGPIODriver >> port: anObject [
	port := anObject
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
