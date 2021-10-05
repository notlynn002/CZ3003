extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func raise_invalid_parameter_error(message: String) -> int:
	var function: String = get_stack()[1]["function"]
	print ("[Invalid Parameter Error] >> %s(): %s" % [function, message])
	return ERR_INVALID_PARAMETER
