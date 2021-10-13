extends StaticBody2D


# Declare member variables here. Examples:
var questionNumber
var question

func init(qnID, qn):
	questionNumber = qnID
	question = qn
	
func _ready():
	$CollisionShape2D/Background/QuestionNumber.text = questionNumber + '.'
	$CollisionShape2D/Background/Question.text = question 
