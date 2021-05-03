Class {
	#name : #PiGPIOEventLoop,
	#superclass : #Object,
	#instVars : [
		'eventStream',
		'pinStatus',
		'running',
		'handle',
		'monitor',
		'eventLevels',
		'lastLevel',
		'listenProcess'
	],
	#classInstVars : [
		'stop'
	],
	#category : #PiGPIO
}

{ #category : #initialization }
PiGPIOEventLoop >> initialize [ 
	super initialize.
	running := false.
	monitor := 0. "bits to monitor"
	eventLevels := 0. "events to monitor"
	running := false
	
]

{ #category : #initialization }
PiGPIOEventLoop >> openStreamOn: anIP port: aPortNumber [ 
	eventStream := SocketStream openConnectionToHostNamed: anIP port: aPortNumber.
]

{ #category : #utilities }
PiGPIOEventLoop >> packedCommand: cmdNr p1: param1 p2: param2 [
	| commandBuffer |
	commandBuffer := ByteArray new: 16.
	commandBuffer  unsignedLongAt: 1 put: cmdNr ;
					unsignedLongAt: 5 put: param1;
					unsignedLongAt: 9 put: param2;
					unsignedLongAt: 13 put: 0.
	^commandBuffer
]

{ #category : #accessing }
PiGPIOEventLoop >> processEvents [ 
	"loop to get event messages from the eventStream"
	| message seq flags ticks levels |
		[ running ] whileTrue: [  
		message := eventStream next: 12.
		message traceCr. ]
]

{ #category : #'as yet unclassified' }
PiGPIOEventLoop >> readBank1 [
	"readBank1 drom the eventStream
	command BR1 = 10	"
		| answer result |
	eventStream nextPutAll: (self packedCommand: 10 p1: 0 p2: 0); flush.
	answer := (eventStream next: 16) asByteArray .
	result := answer signedLongAt: 13.
	self assert: (result >= 0) description: ('error code: ', result printString ) .
	^(answer allButFirst: 12) unsignedLong at: 1
	 
	
]

{ #category : #accessing }
PiGPIOEventLoop >> start [ 
	"this was called from PiGPIO "
	"we can suppose the eventStream is opened."
	lastLevel := 0.
	listenProcess := [ self processEvents ] forkNamed: 'PiGPIO event loop'
]

{ #category : #accessing }
PiGPIOEventLoop >> stop [
	running := false.
	

]
