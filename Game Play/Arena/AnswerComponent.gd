extends StaticBody2D
signal answered

# Declare member variables here. Examples:
var answer
var correctAns
var questionID

func init(qnID, ans, rightAns):
	questionID = qnID
	answer = ans
	correctAns = rightAns

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D/AnsButton/Answer.text = answer

func _on_AnsButton_pressed():
	if correctAns:
		Globals.score += 1
		var try = [questionID, true]
		Globals.attempt.append(try)
	else:
		var try = [questionID, false]
		Globals.attempt.append(try)
	emit_signal('answered')

