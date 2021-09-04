"
I am triggered every 60 seconds by the picod daemon on the Pico.
I have the accessors flags (inprinciple this should be 16r40), levels (all pins) and ticks ( the internal clock of the picod)
"
Class {
	#name : #PiGPIOAlive,
	#superclass : #Announcement,
	#instVars : [
		'flags',
		'ticks',
		'levels'
	],
	#category : #PiGPIO
}

{ #category : #accessing }
PiGPIOAlive >> flags [
	^ flags
]

{ #category : #accessing }
PiGPIOAlive >> flags: anObject [
	flags := anObject
]

{ #category : #accessing }
PiGPIOAlive >> levels [
	^ levels
]

{ #category : #accessing }
PiGPIOAlive >> levels: anObject [
	levels := anObject
]

{ #category : #accessing }
PiGPIOAlive >> ticks [
	^ ticks
]

{ #category : #accessing }
PiGPIOAlive >> ticks: anObject [
	ticks := anObject
]
