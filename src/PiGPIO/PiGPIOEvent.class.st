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
		'tick'
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
PiGPIOEvent >> tick [

	^ tick
]

{ #category : #accessing }
PiGPIOEvent >> tick: anObject [

	tick := anObject
]
