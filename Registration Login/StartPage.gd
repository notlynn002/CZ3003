extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_RegisterButton_pressed():
	# navigate to page where they can register as teacher or student
	get_tree().change_scene("res://Registration Login/Registration/RegisterRoleSelectPage.tscn")


func _on_LoginButton_pressed():
	# navigate to page where they can login as teacher or student
	get_tree().change_scene("res://Registration Login/Login/LoginRoleSelectPage.tscn")

	

