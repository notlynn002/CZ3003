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


func send_quiz_notification_to_students(studentIdList):
	var collection : FirestoreCollection = Firebase.Firestore.collection('Notification')
	var message = 'You have a new quiz to do!'
	var notificationType = 'new quiz'
	var time = OS.get_unix_time()
	#for studentId in studentIdList:
		
		#var task: FirestoreTask
		#var collection: FirestoreCollection = Firebase.Firestore.collection("Question_Attempt")
		#for question_attempt in question_attempts:
		#question_attempt["studentID"] = student_id
		#task = collection.add("", question_attempt)
		#yield(task, "task_finished")
		#print(studentId)

# For sending notifications to students when new quiz is created
func _on_New_Quiz_Notification_button_up():
	var studentList = ['asd','wqe','zxc']
	send_quiz_notification_to_students(studentList)
	pass # Replace with function body.
