"
I listen on a different socket for notifications, These can be for pin change, events or a watchdog on a pin. For each message an appropriate announcement is fired.
I am created by PiGPIO class>>onIP:port:
and started with PiGPIO>>startEventLoop
Clearly the ip and port should be identical to those used by PiGPIO
"
Class {
	#name : #ManifestPiGPIO,
	#superclass : #PackageManifest,
	#category : #'PiGPIO-Manifest'
}
