"
I am (will be) the reification of the connection to a SPI device.
To be done

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	handle:		<Object>
	piGPIO:		<Object>


    Implementation Points
"
Class {
	#name : #PiGPIOSPIConnection,
	#superclass : #Object,
	#instVars : [
		'piGPIO',
		'handle'
	],
	#category : #PiGPIO
}
