extends CanvasLayer


# Declare member variables here. Examples:
var questionNumber
var questionContent
var wrongOption1
var wrongOption2
var WrongOption3
var correctOption

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SaveButton_pressed():
	questionNumber = $QuestionNumberInput.text
	questionContent = $QuestionContentInput.text
	wrongOption1 = $WrongOptionInput1.text
	wrongOption2 = $WrongOptionInput2.text
	WrongOption3 = $WrongOptionInput3.text
	correctOption = $CorrectOptionInput.text
	# save to db


func _on_CancelButton_pressed():
	self.queue_free()
