smon = require '../src/stormmonitor'
SMON = new smon 10000
SMON.on 'results',(result) ->
	console.log "Event results received"
	console.log result
SMON.addpid(3629)
SMON.run()

