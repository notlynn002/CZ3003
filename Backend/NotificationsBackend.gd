extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Pass in the user_id for which notifications you would like to get.
# Returns a list of notification documents
func get_notification_for_user(user_id):
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Notification')
	query.where('receiverID', FirestoreQuery.OPERATOR.EQUAL, user_id)
	query.order_by('creationDateTime', FirestoreQuery.DIRECTION.DESCENDING)

	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	return result

func _on_Get_Notifications_for_User_button_up():
	var all_notifications = yield(get_notification_for_user('HjgDICIEdI4btnow8RP6'), 'completed')
	print(all_notifications)

# Need find a way to convert time to datetimestamp
# For sending notifications to students when new quiz is created
func send_quiz_notification_to_students(studentIdList):
	var notification = {
		'message' : 'You have a new quiz to do!',
		'notificationType' : 'new quiz',
		'creationDateTime' : OS.get_unix_time()
	}
	var task: FirestoreTask
	var collection : FirestoreCollection = Firebase.Firestore.collection('Notification')
	
	for studentId in studentIdList:
		notification['receiverID'] = studentId
		task = collection.add("", notification)
		yield(task, "task_finished")

func _on_New_Quiz_Notification_button_up():
	var studentList = ['asd','wqe','zxc']
	send_quiz_notification_to_students(studentList)
	pass # Replace with function body.


# Check creation date time datastructure - same as quiz
# When challenge has been completed by challengee, send challenge completed notification back to challenger
func send_challenge_completed_notification(challengerID):
	var notification = {
		'message' : 'Your challenge has been completed.',
		'notificationType' : 'completed challenge',
		'creationDateTime' : OS.get_unix_time(),
		'receiverID' : challengerID
	}
	
	var collection : FirestoreCollection = Firebase.Firestore.collection('Notification')
	var task : FirestoreTask
	
	task = collection.add('', notification)
	yield(task, "task_finished")
	
func _on_Send_challenge_completed_notification_button_up():
	send_challenge_completed_notification('student-1')

# When challenge is declined, send notification  to challenger
func send_challenge_declined_notification(challengerID):
	var notification = {
		'message' : 'Your challenge has been declined.',
		'notificationType' : 'challenge declined',
		'creationDateTime' : OS.get_unix_time(),
		'receiverID' : challengerID
	}
	
	var collection : FirestoreCollection = Firebase.Firestore.collection('Notification')
	var task : FirestoreTask
	
	task = collection.add('', notification)
	yield(task, "task_finished")
	
func _on_Send_challenge_declined_notification2_button_up():
	send_challenge_declined_notification('student-1')
