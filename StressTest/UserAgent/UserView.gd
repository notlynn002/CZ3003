extends PanelContainer

signal finished(id, data)
# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
export var email : String
export var password : String
export var iterations : int
export var id : int

var times = Array()
var max_time : int = 0
var sum_time : int = 0
onready var user_agent = $"UserAgent"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"VBoxContainer/ColorRect".color = Color.yellow
	randomize()
	user_agent.email = email
	user_agent.password = password
	user_agent.num_iterations = iterations
	print(user_agent.email)
	user_agent.start()
	pass # Replace with function body.



func _on_UserAgent_status_changed() -> void:
	user_agent.run()
	if user_agent.status == user_agent.Status.AUTH:
		$"VBoxContainer/ColorRect".color = Color.chartreuse
	else:
		$"VBoxContainer/ColorRect".color = Color.orangered
	pass # Replace with function body.


func _on_UserAgent_iteraion_complete(time) -> void:
	times.push_back(time)
	var avg : int = 0
	max_time = max(max_time, time)
	sum_time += time
	$"VBoxContainer/Max/Value".text = "%d ms" % max_time
	$"VBoxContainer/Avg/Value".text = "%d ms" % (sum_time/times.size())
	$"VBoxContainer/Last/Value".text = "%d ms" % time
	$"VBoxContainer/Count/Value".text = "%d" % times.size()
	
	pass # Replace with function body.
