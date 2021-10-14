extends Node

static func await_any_signal(args):
	assert(len(args) % 2 == 0)
	var emitter = _Emitter.new()
	for i in range(0, len(args), 2):
		var object = args[i]
		var signal_name = args[i + 1]
		object.connect(signal_name, emitter, "emit")
	yield(emitter, 'emitted')

static func await_all_signals(args):
	assert(len(args) % 2 == 0)
	var emitter = _Emitter.new()
	for i in range(0, len(args), 2):
		var object = args[i]
		var signal_name = args[i + 1]
		object.connect(signal_name, emitter, 'emit')
	#warning-ignore:unused_variable
	for i in range(0, len(args), 2):
		yield(emitter, 'emitted')

class _Emitter:
	signal emitted
	func emit():
		emit_signal("emitted")
