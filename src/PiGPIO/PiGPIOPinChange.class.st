"
I announce the change of a pin level The subscriber can retrieve three items: 
pinNr - the pin number 
newLevel - the now pin level (0, 1)
tick - the value of the pigpiod clock (rolllover after ca 70 minutes; use PiGPIO>> tickDiffFrom:to: to calculate elapsed times)
"
Class {
	#name : #PiGPIOPinChange,
	#superclass : #Announcement,
	#instVars : [
		'pinNr',
		'newLevel',
		'tick'
	],
	#category : #PiGPIO
}

{ #category : #accessing }
PiGPIOPinChange >> newLevel [
	^ newLevel
]

{ #category : #accessing }
PiGPIOPinChange >> newLevel: anObject [
	newLevel := anObject
]

{ #category : #accessing }
PiGPIOPinChange >> pinNr [
	^ pinNr
]

{ #category : #accessing }
PiGPIOPinChange >> pinNr: anObject [
	pinNr := anObject
]

{ #category : #accessing }
PiGPIOPinChange >> tick [
	^ tick
]

{ #category : #accessing }
PiGPIOPinChange >> tick: anObject [
	tick := anObject
]
