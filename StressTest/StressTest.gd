extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
enum States {
	IDLE,
	PROCESSING,
	FINISHED,
}

var full_data = Array()
var remaining : int
var _state = States.IDLE setget set_state, get_state
func set_state(value : int):
	if _state != value:
		_state = value
		match _state:
			States.IDLE:
				$"HBoxContainer/SideBar/Controls/StartButton".disabled = false
				$"HBoxContainer/SideBar/Controls/ExportButton".disabled = true
				$"HBoxContainer/SideBar/Controls/Iterations/Value".editable = false
				$"HBoxContainer/SideBar/Controls/Users/Value".editable = false
			States.PROCESSING:
				$"HBoxContainer/SideBar/Controls/StartButton".disabled = true
				$"HBoxContainer/SideBar/Controls/ExportButton".disabled = true
				$"HBoxContainer/SideBar/Controls/Iterations/Value".editable = false
				$"HBoxContainer/SideBar/Controls/Users/Value".editable = false
			States.FINISHED:
				$"HBoxContainer/SideBar/Controls/StartButton".disabled = true
				$"HBoxContainer/SideBar/Controls/ExportButton".disabled = false
				$"HBoxContainer/SideBar/Controls/Iterations/Value".editable = false
				$"HBoxContainer/SideBar/Controls/Users/Value".editable = false

func get_state() -> int:
	return _state
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_state(States.IDLE)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_StartButton_pressed() -> void:
	set_state(States.PROCESSING)
	var user_count = $"HBoxContainer/SideBar/Controls/Users/Value".value
	var iteration_count = $"HBoxContainer/SideBar/Controls/Iterations/Value".value
	full_data.resize(user_count)
	remaining = user_count
	for i in user_count:
		var email = "%d@stress.test" % i
		var password = "stresstest%d" % i
		var user_view = preload("res://StressTest/UserAgent/UserView.tscn").instance()
		user_view.connect("finished", self, "_on_user_finished")
		user_view.email = email
		user_view.password = password
		user_view.iterations = iteration_count
		user_view.id = i
		$"HBoxContainer/ScrollContainer/UserViews".add_child(user_view)
	pass # Replace with function body.

func _on_user_finished(id : int, data : Array):
	full_data[id] = data
	remaining -= 1
	if remaining == 0:
		set_state(States.FINISHED)


func _on_ExportButton_pressed() -> void:
	$"FileDialog".popup_centered()
	pass # Replace with function body.


func _on_FileDialog_file_selected(path: String) -> void:
	var file = File.new()
	file.open(path, File.WRITE)
	for i in full_data.size():
		var line = PoolStringArray()
		for j in full_data[i]:
			line.append(str(j))
		file.store_csv_line(line, ",")
	file.close()
			
	print("saved")
	pass # Replace with function body.
