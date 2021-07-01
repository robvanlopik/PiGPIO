Class {
	#name : #BaselineOfPiGPIO,
	#superclass : #BaselineOf,
	#category : #BaselineOfPiGPIO
}

{ #category : #baselines }
BaselineOfPiGPIO >> baseline: spec [
		<baseline>
		spec 
			for: #common 
			do: [ 
				spec package: 'PiGPIO' ].
]
