extends CanvasLayer


# Declare member variables here. Examples:
var quizName
var quizDurationHour = 0
var quizDurationMin = 0
var quizAttempts = 1
var quizTopic = 'Fractions'
var quizDay = 1
var quizMonth = 1
var quizYear = 2021
var quizTimeHour = 0
var quizTimeMin = 0
var selectedClasses = []
export (PackedScene) var questionNode

func init():
	print(Globals.get('quizQuestions'))
	
# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")
	$PublishPopup.hide()
	# init 
	$HourDropdown.clear()
	$PublishPopup/HoursOptionButton.clear()
	for i in 24:
		$HourDropdown.add_item(str(i), i)
		$PublishPopup/HoursOptionButton.add_item(str(i), i)
	$MinDropdown.clear()
	$PublishPopup/MinsOptionButton.clear()
	for i in 60:
		$MinDropdown.add_item(str(i), i)
		$PublishPopup/MinsOptionButton.add_item(str(i), i)
	$TriesDropdown.clear()
	for i in 10:
		$TriesDropdown.add_item(str(i+1), i)
	$PublishPopup/DayDropdown.clear()
	for i in 31:
		$PublishPopup/DayDropdown.add_item(str(i+1), i)
	$PublishPopup/MonthOptionButton.clear()
	for i in 12:
		$PublishPopup/MonthOptionButton.add_item(str(i+1), i)
	$PublishPopup/YearOptionButton.clear()
	for i in 5:
		$PublishPopup/YearOptionButton.add_item(str(2020+i+1), 2020+i);
	
	var arr = Globals.get('quizQuestions')
	print(arr)
	for i in range(arr.size()):
		var qnNode = questionNode.instance()
		qnNode.init(i+1, arr[i]['qnContent'], arr[i])
		$ScrollContainer/VBoxContainer.add_child(qnNode)
		# add_child(qnNode)
	
func _on_HourDropdown_item_selected(index):
	quizDurationHour = index


func _on_TriesDropdown_item_selected(index):
	quizAttempts = index+1


func _on_TopicDropdown_item_selected(index):
	if index == 0:
		quizTopic = 'Fractions'
	elif index == 1:
		quizTopic = 'Ratio'
	else:
		quizTopic = 'Numbers'


func _on_MinDropdown_item_selected(index):
	quizDurationMin = index



func _on_PublishButton_pressed():
	$PublishPopup.show()


func _on_AddQnButton_pressed():
	var root = get_tree().root
	var addQnPage = preload('res://Teacher/create quiz/AddQuestionPage.tscn').instance()
	root.add_child(addQnPage)
	


func _on_HoursOptionButton_item_selected(index):
	quizTimeHour = index
	if quizTimeMin < 10 && quizTimeHour < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + '0' + str(quizTimeHour) + ':' + '0' + str(quizTimeMin)
	elif quizTimeMin < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + str(quizTimeHour) + ':' + '0' + str(quizTimeMin)
	elif quizTimeHour < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + '0' +  str(quizTimeHour) + ':' + str(quizTimeMin)
	else:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + str(quizTimeHour) + ':' + str(quizTimeMin)


func _on_MinsOptionButton_item_selected(index):
	quizTimeMin = index
	if quizTimeMin < 10 && quizTimeHour < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + '0' + str(quizTimeHour) + ':' + '0' + str(quizTimeMin)
	elif quizTimeMin < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + str(quizTimeHour) + ':' + '0' + str(quizTimeMin)
	elif quizTimeHour < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + '0' +  str(quizTimeHour) + ':' + str(quizTimeMin)
	else:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + str(quizTimeHour) + ':' + str(quizTimeMin)

func _on_DayDropdown_item_selected(index):
	quizDay = index+1
	if quizTimeMin < 10 && quizTimeHour < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + '0' + str(quizTimeHour) + ':' + '0' + str(quizTimeMin)
	elif quizTimeMin < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + str(quizTimeHour) + ':' + '0' + str(quizTimeMin)
	elif quizTimeHour < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + '0' +  str(quizTimeHour) + ':' + str(quizTimeMin)
	else:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + str(quizTimeHour) + ':' + str(quizTimeMin)


func _on_MonthOptionButton_item_selected(index):
	quizMonth = index+1
	if quizTimeMin < 10 && quizTimeHour < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + '0' + str(quizTimeHour) + ':' + '0' + str(quizTimeMin)
	elif quizTimeMin < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + str(quizTimeHour) + ':' + '0' + str(quizTimeMin)
	elif quizTimeHour < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + '0' +  str(quizTimeHour) + ':' + str(quizTimeMin)
	else:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + str(quizTimeHour) + ':' + str(quizTimeMin)


func _on_YearOptionButton_item_selected(index):
	quizYear = 2020+index+1
	if quizTimeMin < 10 && quizTimeHour < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + '0' + str(quizTimeHour) + ':' + '0' + str(quizTimeMin)
	elif quizTimeMin < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + str(quizTimeHour) + ':' + '0' + str(quizTimeMin)
	elif quizTimeHour < 10:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + '0' +  str(quizTimeHour) + ':' + str(quizTimeMin)
	else:
		$PublishPopup/PublishDateTime.text = 'Publish on: ' + str(quizDay) + '/' + str(quizMonth) + '/' + str(quizYear) + ' ' + str(quizTimeHour) + ':' + str(quizTimeMin)


func _on_PublishNowButton_pressed():
	var publishingDateTime = OS.get_datetime()
	quizName = $QuizNameInput.text
	var duration = quizDurationHour*3600 + quizDurationMin*60
	var qns = Globals.get('quizQuestions')
	create_quiz(quizTopic, selectedClasses, quizName, duration, quizAttempts, publishingDateTime, qns)
	self.queue_free()
	get_node('/root/QuizCreationPage').queue_free()


func _on_ScheduleButton_pressed():
	var publishingDateTime = Datetime.get_datetime_dict(quizYear, quizMonth, quizDay, quizTimeHour, quizTimeMin, false)
	quizName = $QuizNameInput.text
	var duration = quizDurationHour*3600 + quizDurationMin*60
	var qns = Globals.get('quizQuestions')
	print(quizTopic)
	print(selectedClasses)
	print(quizName)
	print(duration)
	print(quizAttempts)
	print(publishingDateTime)
	print(qns)
	create_quiz(quizTopic, selectedClasses, quizName, duration, quizAttempts, publishingDateTime, qns)
	self.queue_free()
	get_node('/root/QuizCreationPage').queue_free()


func _on_PopupCloseButton_pressed():
	$PublishPopup.hide()


func _on_CloseButton_pressed():
	self.queue_free()


func _on_4FCheckBox_pressed():
	selectedClasses.append('4F')


func _on_4GCheckBox_pressed():
	selectedClasses.append('4G')


##### BACKEND FUNCTION #######
func create_quiz(quiz_tower_id: String, class_ids: Array, quiz_name: String, max_time: int, no_of_tries: int, publishing_date, questions: Array):
	"""Create a quiz and writes it to the database.
	
	Args:
		quiz_tower_id (String): Tower ID of the quiz tower.
		class_ids (Array[String]): List of class ID of that class that the quiz is assigned to.
		quiz_name (String): Quiz name.
		max_time (int): Maximum time that a student is allowed for the quiz, formatted as total seconds.
		no_of_tries (int): Maximum number of tries that a student is allowed for the quiz.
		publishing_date (Dictionary): Quiz publishing date in UTC time, formatted as a datetime Dictionary.
		questions (Array[Dictionary]): Quiz questions as Dictionary objects.
			All Dictionary keys should be Strings.
			Each Dictionary should contains following keys-value pairs:
				questionBody (String): Question body.
				questionOptions (Array[String]): Question options.
				questionSoln (String): Question solution.
				questionExplanation (String): Question explanation.
	
	Raises:
		ERR_INVALID_PARAMETER: If a parameter has an invalid value or if a quiz has the same name as an existing quiz (case sensitive).
	
	"""
	# Create quiz dictionary
	var quiz: Dictionary = {
		"towerID": quiz_tower_id,
		"levelDuration": max_time,
		"levelType": "quiz",
		"quizName": quiz_name,
		"attemptNo": no_of_tries,
		"publishingDate": publishing_date,
		"questions": questions
	}
	"""
	# Check quiz fields
	if Error.check_quiz(quiz, false) != OK:
		return Error.raise_invalid_parameter_error("Invalid quiz argument passed.")
	"""

	# Write quiz level to Level collection
	# Create quiz id
	var quiz_level_id: String = "quiz-" + quiz["quizName"].replace(" ", "-")
	# remove questions from quiz dict
	quiz.erase("questions")
	# write data to level collection
	var collection: FirestoreCollection = Firebase.Firestore.collection("Level")
	var task: FirestoreTask = collection.add(quiz_level_id, quiz)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		return Error.raise_invalid_parameter_error("'%s' is already the name of an existing quiz" % quiz["quizName"])
	
	# Add questions
	collection = Firebase.Firestore.collection("Question")
	for question in questions:
		question["levelID"] = quiz_level_id
		task = collection.add("", question)
		yield(task, "task_finished")
	
	# Add quiz id to class
	# Check if class_id is valid
	collection = Firebase.Firestore.collection("Class")
	var quiz_list
	for class_id in class_ids:
		quiz_list = yield(get_quiz_ids_by_class(class_id), "completed")
		if not quiz_list is Array:
			Error.raise_invalid_parameter_error("'%s is not a valid class ID" % class_id)
			continue
		quiz_list.append(quiz_level_id)
		task = collection.update(class_id, {"quizList": quiz_list})
		yield(task, "task_finished")
		
func get_quiz_ids_by_class(class_id: String) -> Array:
	""" Get the quiz level IDs for a class.
	
	Args:
		class_id (String): Class ID.
	
	Returns:
		Array[String]: The quiz level IDs as Strings.
	
	Raises:
		ERR_INVALID_PARAMETER: If the class ID is invalid.
	
	"""
	var collection: FirestoreCollection = Firebase.Firestore.collection("Class")
	var task: FirestoreTask = collection.get(class_id)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		return Error.raise_invalid_parameter_error("'%s is not a valid class ID" % class_id)
	return doc.doc_fields["quizList"]
