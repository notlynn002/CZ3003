extends CanvasLayer


# Declare member variables here. Examples:
var questionContent = ''
var wrongOption1 = ''
var wrongOption2 = ''
var wrongOption3 = ''
var correctOption = ''
var mode = 'create'
var questionDict
var questionID

func init(qnDict, qnID):
	questionDict = qnDict
	questionID = qnID
	questionContent = qnDict['qnContent']
	wrongOption1 = qnDict['wrongOption1']
	wrongOption2 = qnDict['wrongOption2']
	wrongOption3 = qnDict['wrongOption3']
	correctOption = qnDict['correctOption']
	mode = 'edit'

# Called when the node enters the scene tree for the first time.
func _ready():
	$QuestionContentInput.text = questionContent
	$WrongOptionInput1.text = wrongOption1
	$WrongOptionInput2.text = wrongOption2
	$WrongOptionInput3.text = wrongOption3
	$CorrectOptionInput.text = correctOption
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SaveButton_pressed():
	if mode == 'create':
		questionContent = $QuestionContentInput.text
		wrongOption1 = $WrongOptionInput1.text
		wrongOption2 = $WrongOptionInput2.text
		wrongOption3 = $WrongOptionInput3.text
		correctOption = $CorrectOptionInput.text
		var qn = {'qnContent': questionContent, 
				  'wrongOption1': wrongOption1, 
				  'wrongOption2': wrongOption2, 
				  'wrongOption3': wrongOption3, 
				  'correctOption': correctOption}
		Globals.get('quizQuestions').append(qn)
	elif mode == 'edit':
		questionDict['qnContent'] = $QuestionContentInput.text
		questionDict['wrongOption1'] = $WrongOptionInput1.text
		questionDict['wrongOption2'] = $WrongOptionInput2.text
		questionDict['wrongOption3'] = $WrongOptionInput3.text
		questionDict['correctOption'] = $CorrectOptionInput.text
		Globals.get('quizQuestions')[questionID] = questionDict
	var root = get_tree().root
	var quizPg = load("res://Teacher/create quiz/QuizCreationPage.tscn").instance()
	root.add_child(quizPg)
	self.queue_free()
	
	

func _on_CancelButton_pressed():
	self.queue_free()
