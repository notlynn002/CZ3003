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
	query.order_by('creationDateTime', FirestoreQuery.DIRECTION.ASCENDING)

	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	print(result)

func _on_Get_Notifications_for_User_button_up():
	get_notification_for_user('HjgDICIEdI4btnow8RP6')
	pass

# Need find a way to convert time to datetimestamp
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
	print('Notifications added')

# For sending notifications to students when new quiz is created
func _on_New_Quiz_Notification_button_up():
	var studentList = ['asd','wqe','zxc']
	send_quiz_notification_to_students(studentList)
	pass # Replace with function body.
