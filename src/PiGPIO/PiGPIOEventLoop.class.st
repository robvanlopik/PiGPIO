"
Irun a thread listening on a socket stream. when opening the stream a retrieve a handle that is used by PiGPIO to specify what to monitor.

My SocketStream has a time-ut of 70, longer than the ALIVE message interval
 of 60 seconds, so it should never occur.

I generate 3 announcements:
PiGPIOPinChange when a pin that is monitored (by PiGPIO>>pinsToWatch) 
changes state. More than 1 pin can change state during the same tick, 
but these are reported separately.
PiGPIOWatchdog when a watchdog timer is set for a pin and 
it does not hange in the time specified.
PiGPIOEvent when a event (0-31) is triggered by PiGPIO>>triggerEvent:
"
Class {
	#name : #PiGPIOEventLoop,
	#superclass : #Object,
	#instVars : [
		'eventStream',
		'running',
		'handle',
		'lastLevels',
		'listenProcess',
		'announcer',
		'pinsToMonitor',
		'eventsToMonitor'
	],
	#classInstVars : [
		'stop'
	],
	#category : #PiGPIO
}

{ #category : #accessing }
PiGPIOEventLoop >> announcer [
	^announcer
]

{ #category : #'announcement handling' }
PiGPIOEventLoop >> emitAnnouncements: flags levels: levels ticks: ticks [
	"look at the flags and emit announcements. These are made in a different thread 
	to avoid blocking the wvent listener	"
			| changed |
	(flags = 0) ifTrue: [ 
		changed := lastLevels bitXor: levels. "which bits changed?"
		lastLevels := levels.
		changed := changed bitAnd: pinsToMonitor. "changed AND being monitored"
		0 to: 31 do: [ :pinNr | ((changed bitAt: (pinNr + 1)) = 1) ifTrue:
			[[ announcer announce: (PiGPIOPinChange new pinNr: pinNr; 
				newLevel: (levels bitAt: (pinNr + 1)); tick: ticks; yourself ) ] 
					forkAt: Processor userInterruptPriority ].
			].
			^self].
		
		"test for watchdog"
		((flags bitAnd: (1 << 5)) ~= 0) ifTrue: [[
			 announcer announce: (PiGPIOWatchdog new pinNr: (flags bitAnd: 16r1F);
				tick: ticks; yourself)]
					forkAt: Processor userInterruptPriority .
			^self].
		
		"test for event"
		((flags bitAnd: (1 << 7)) ~= 0) ifTrue: [[
			 announcer announce: (PiGPIOEvent new 
				eventNr: (flags bitAnd: 16r1F); tick: ticks; yourself).]
					forkAt: Processor userInterruptPriority .
			^self].
		
		"show the ALIVE message. SHOULD BE REMOVED"
		((flags bitAnd: (1 << 6) ) ~= 0) ifTrue: [ 
			(Time now print24, 'KeepAlive ') traceCr. ^self].
]

{ #category : #'as yet unclassified' }
PiGPIOEventLoop >> eventsToMonitor: bitMask [
	"selection of possible events to report"	
			
	eventsToMonitor := bitMask
]

{ #category : #accessing }
PiGPIOEventLoop >> getHandle [
	"get a handle  from the eventStream
	command NOIB = 99	"
		| answer result |
	eventStream nextPutAll: (self packedCommand: 99 p1: 0 p2: 0); flush.
	answer := (eventStream next: 16) asByteArray .
	result := answer unsignedLongAt: 13.
	^result
]

{ #category : #accessing }
PiGPIOEventLoop >> handle [
	^handle
]

{ #category : #initialization }
PiGPIOEventLoop >> initialize [ 
	super initialize.
	running := false.
	pinsToMonitor := 0. "bits to monitor"
	eventsToMonitor := 0. "events to monitor"
	announcer := Announcer new
	
]

{ #category : #initialization }
PiGPIOEventLoop >> openStreamOn: anIP port: aPortNumber [ 
	eventStream := SocketStream openConnectionToHostNamed: anIP port: aPortNumber.
	eventStream binary.
	eventStream timeout: 70. "In principle a message with flag ALIVE should arrive every 60 seconds"
	
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

{ #category : #'as yet unclassified' }
PiGPIOEventLoop >> pinsToMonitor: bitmask [
	"can i do this without mutex?"
	pinsToMonitor := bitmask
]

{ #category : #accessing }
PiGPIOEventLoop >> processEvents [ 
	"loop to get event messages from the eventStream and fire announcements"
	| message seq flags ticks levels |
		[[ running ] whileTrue: [  
			message := eventStream next: 12.
			(message size ~= 12) ifTrue: [ (Time now print24, 'wrong size') traceCr ]
			ifFalse: [ 
			seq := message unsignedShortAt: 1.
			flags := message unsignedShortAt: 3.
			ticks := message unsignedLongAt: 5.
			levels := message unsignedLongAt: 9.
			self emitAnnouncements: flags levels: levels ticks: ticks.]
		] ] ensure: [  eventStream close ] 
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
	^(answer allButFirst: 12) unsignedLongAt: 1
	 
	
]

{ #category : #accessing }
PiGPIOEventLoop >> start [ 
	"this was called from PiGPIO "
	"we can suppose the eventStream is opened."
	lastLevels := self readBank1 .
	handle := self getHandle.
	running := true.
	listenProcess := [ self processEvents ] forkAt: Processor lowIOPriority  named: 'PiGPIO event loop'
]

{ #category : #accessing }
PiGPIOEventLoop >> stop [
	"stop the eventloop and sclose the stream. Also tell PiGPIO to stop notifications
	with command: CMD_NC = 21"
	
	eventStream nextPutAll: (self packedCommand: 21 p1: handle  p2: 0).
	running := false.
	

]
