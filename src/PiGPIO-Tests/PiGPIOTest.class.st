Class {
	#name : #PiGPIOTest,
	#superclass : #TestCase,
	#instVars : [
		'pigpio'
	],
	#category : #'PiGPIO-Tests'
}

{ #category : #running }
PiGPIOTest >> setUp [
	super setUp.
	pigpio := MockObject new
	"Put here a common initialization logic for tests"
]
