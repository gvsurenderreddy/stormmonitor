os = require 'os'
exec = require('child_process').exec
fs = require 'fs'
EventEmitter = require('events').EventEmitter

cpu_pids = []

past = []
current = []
actual = []
pids = []
process = []


measureMemory = ()->
	data = fs.readFileSync("/proc/meminfo")	
	String output = data.toString()	
	tmparr = output.split "\n"            
	memory = {}
	count = 1
	for i in tmparr		
		tmpvars = i.split(/[ ]+/)	
		if tmpvars[0] is "MemTotal:"
			memory.total =  tmpvars[1]				
		if tmpvars[0] is "MemFree:"
			memory.free =  tmpvars[1]				
			return memory
		count++
	return

measureCPU = ()->
	cpu = {}
	cpu.total = 0
	cpu.idle = 0
	cpu.used = 0
	data = fs.readFileSync("/proc/stat")	
	String output = data.toString()	
	tmparr = output.split "\n"         
	current = tmparr[0].split (/[ ]+/)
	unless past[0]?
		past = current
		return cpu
	actual[0] = current[1] - past[1]
	actual[1] = current[2] - past[2]
	actual[2] = current[3] - past[3]
	actual[3] = current[4] - past[4]
	actual[4] = current[5] - past[5]
	past = current

	cpu.total = actual[0] + actual[1] + actual[2] + actual[3] + actual[4]
	#console.log "totalCPU", totalCPU
	cpu.idle = ( actual[3] / cpu.total) * 100
	#console.log "idle",idle
	cpu.used =  (actual[0] + actual[1] + actual[2] + actual[4] ) / cpu.total * 100
	#console.log "used",used
	return cpu


measurePID = (pid , cputotal)->
	#CPU Measurement	
	result = {}
	if cpu_pids[pid]?
		result = cpu_pids[pid]
	console.log result
	result.pid ?= pid	
	data = fs.readFileSync("/proc/#{pid}/stat")	
	String output = data.toString()	
	tmpvars = output.split(/[ ]+/)
	#console.log tmpvars[15] 
	#console.log tmpvars[16]
	#utime stime
	cpuused = Number(tmpvars[13]) + Number(tmpvars[14])		
	console.log result.prevcpu
	if result.prevcpu?
		result.actualcpu = cpuused - result.prevcpu 		
	result.prevcpu = cpuused
	result.cpu = ( result.actualcpu / cputotal ) * 100

	cpu_pids[pid] = result
	#unless cpu_pids[pid]?
	#	cpu_pids[pid].push result

	return result
	#Memory Measurement	
	###
	data = fs.readFileSync("/proc/#{pid}/status")	
	String output = data.toString()	
	tmparr = output.split "\n"            	
	count = 1
	for i in tmparr		
		tmpvars = i.split(/[ ]+/)	
		if tmpvars[0] is "VmSize:"
			result.memory = tmpvars[1] 				
			return result
		count++
	return result
	###

class StormMonitor extends EventEmitter

	constructor: (interval) -> 
		@timeout = interval	

	monitor : () =>
		@pidresults = []
		@memory = measureMemory()
		@cpu = measureCPU()
		console.log @cpu
		#console.log pids
		for pid in pids
			console.log @cpu
			@pidresults.push measurePID(pid,@cpu.total)
		#console.log @cpu
		#console.log @memory
		#console.log @pidresults
		result = {}
		result.system = {}
		result.pids = []
		result.system.memory = @memory
		result.system.cpu = @cpu
		result.pids = @pidresults
		@emit 'results',result

	run : () =>	
		@monitor()	
		setInterval(@monitor,@timeout)

	addpid : (pid) =>
		pids.push pid
	status : () =>
		cpu : @cpu
		memory : @memory


		
module.exports = StormMonitor