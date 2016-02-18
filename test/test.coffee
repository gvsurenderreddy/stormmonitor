smon = require '../src/stormmonitor'
SMON = new smon 10000
#SMON.on 'results',(result) ->
#	console.log "Event results received"
#	console.log result

SMON.addpid(6692)
SMON.run()

setTimeout ()->
	SMON.addpid(3861)
,15000

setTimeout ()->
	SMON.removepid(6692)
,30000

setTimeout ()->
	SMON.addpid(6692)
	console.log SMON.status()
,50000

setTimeout ()->
	SMON.removepid(3861)
,90000

