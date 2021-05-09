"
I announce the expiration of a watchdog timer for a pin.
This has been set by PiGPIO>>setWatchdogOnPin:timeout:
It means this time elapsed sinse the last pinchange or watchdog event.
We return the pin number and the clock tick
"
Class {
	#name : #PiGPIOPWatchdog,
	#superclass : #Announcement,
	#instVars : [
		'pinNr',
		'tick'
	],
	#category : #PiGPIO
}

{ #category : #accessing }
PiGPIOPWatchdog >> pinNr [
	^ pinNr
]

{ #category : #accessing }
PiGPIOPWatchdog >> pinNr: anObject [
	pinNr := anObject
]

{ #category : #accessing }
PiGPIOPWatchdog >> tick [
	^ tick
]

{ #category : #accessing }
PiGPIOPWatchdog >> tick: anObject [
	tick := anObject
]
