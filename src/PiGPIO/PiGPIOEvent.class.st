"
I announce an event that has been triggered by PiGPIO>>triggerEvent
I have the event number (0-31) and the ticks when it happened. 
Event 31 is reserved for BSC operations 
"
Class {
	#name : #PiGPIOEvent,
	#superclass : #Announcement,
	#instVars : [
		'eventNr',
		'ticks'
	],
	#category : #PiGPIO
}

{ #category : #accessing }
PiGPIOEvent >> eventNr [

	^ eventNr
]

{ #category : #accessing }
PiGPIOEvent >> eventNr: anObject [

	eventNr := anObject
]

{ #category : #accessing }
PiGPIOEvent >> ticks [

	^ ticks
]

{ #category : #accessing }
PiGPIOEvent >> ticks: anObject [

	ticks := anObject
]
