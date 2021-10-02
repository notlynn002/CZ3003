extends Control


# Declare member variables here. Examples:
var studentName 
var selected = false
var studentIndex


func init(sName, sIndex):
	studentName = sName
	studentIndex = sIndex
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$Button/StudentName.text = studentName


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

	


func _on_Button_pressed():
	if not selected:
		$Button/StudentName.add_color_override("font_color", Color(0,0,0,1))
		selected = true
		SELECTED_CHALLENGEES.append(studentIndex)
	else:
		$Button/StudentName.add_color_override("font_color", Color(255,255,255,1))
		selected = false
		SELECTED_CHALLENGEES.remove(studentIndex)
		
