extends CanvasLayer


# Declare member variables here. Examples:
var questionNumber
var questionContent

func init(qnNo, qnContent):
	questionNumber = qnNo
	questionContent = qnContent

# Called when the node enters the scene tree for the first time.
func _ready():
	$QuestionContent.text = questionContent
	$QuestionNumber.text = questionNumber


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
