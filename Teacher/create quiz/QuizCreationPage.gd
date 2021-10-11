extends CanvasLayer


# Declare member variables here. Examples:
var quizName
var quizDurationHour = 0
var quizDurationMin = 0
var quizAttempts = 1
var quizTopic
var quizDay = 1
var quizMonth = 1
var quizYear = 2021
var quizTimeHour = 0
var quizTimeMin = 0

# Called when the node enters the scene tree for the first time.
func _ready():
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
		
	


func _on_HourDropdown_item_selected(index):
	quizDurationHour = index


func _on_TriesDropdown_item_selected(index):
	quizAttempts = index


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
	# save quix & show quiz immediately in quiz tower
	self.queue_free()


func _on_ScheduleButton_pressed():
	# savq quiz & show quiz during scheduled date time
	self.queue_free()


func _on_PopupCloseButton_pressed():
	$PublishPopup.hide()


func _on_CloseButton_pressed():
	self.queue_free()
