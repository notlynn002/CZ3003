extends StaticBody2D
signal answered

# Declare member variables here. Examples:
var answer
var correct

func init(ans, right):
	answer = ans
	correct = right

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D/AnsButton/Answer.text = answer

func _on_AnsButton_pressed():
	if correct:
		Globals.score += 1
	emit_signal('answered')

