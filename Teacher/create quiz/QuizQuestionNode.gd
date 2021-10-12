extends Control


# Declare member variables here. Examples:
var questionNumber
var questionContent
var questionDict

func init(qnNo, qnContent, qnDict):
	questionNumber = qnNo
	questionContent = qnContent
	questionDict = qnDict

# Called when the node enters the scene tree for the first time.
func _ready():
	$QuestionContent.text = questionContent
	$QuestionNumber.text = str(questionNumber)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_EditButton_pressed():
	var root = get_tree().root
	var addQn = preload("res://Teacher/create quiz/AddQuestionPage.tscn").instance()
	addQn.init(questionDict, questionNumber-1)
	root.add_child(addQn)
