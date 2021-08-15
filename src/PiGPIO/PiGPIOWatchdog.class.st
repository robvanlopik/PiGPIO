"
I announce the expiration of a watchdog timer for a pin.
This has been set by PiGPIO>>setWatchdogOnPin:timeout:
It means this time elapsed sinse the last pinchange or watchdog event.
We provide the pin number and the clock tick
"
Class {
	#name : #PiGPIOWatchdog,
	#superclass : #Announcement,
	#instVars : [
		'pinNr',
		'tick'
	],
	#category : #PiGPIO
}

{ #category : #accessing }
PiGPIOWatchdog >> pinNr [
	^ pinNr
]

{ #category : #accessing }
PiGPIOWatchdog >> pinNr: anObject [
	pinNr := anObject
]

{ #category : #accessing }
PiGPIOWatchdog >> tick [
	^ tick
]

{ #category : #accessing }
PiGPIOWatchdog >> tick: anObject [
	tick := anObject
]
