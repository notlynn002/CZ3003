extends CanvasLayer

class_name NotificationsBackend

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Pass in the user_id for which notifications you would like to get.
# Returns a list of notification documents
static func get_notification_for_user(user_id):
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Notification')
	query.where('receiverID', FirestoreQuery.OPERATOR.EQUAL, user_id)
	query.order_by('creationDateTime', FirestoreQuery.DIRECTION.DESCENDING)

	var query_task : FirestoreTask = Firebase.Firestore.query(query) 
	var result = yield(query_task, 'task_finished')
	result.sort_custom(NotificationsSorter, "sort_latest_first") # sorts notifications by creation time 
	
	var final_notifications = []
	for i in result:
		final_notifications.append(i.doc_fields)
	return final_notifications
	

func _on_Get_Notifications_for_User_button_up():
	var userID = 'XKwVQ9EqJ7xjEhHoPr0A'
	var all_notifications = yield(get_notification_for_user(userID), 'completed')
	print(all_notifications)

static func filterChallengeNotification(allNotifications):
	var challengeNotifications = []
	for notification in allNotifications:
		if (notification.notificationType != "new quiz"):
			challengeNotifications.append(notification)
	return challengeNotifications
	
func _on_Filter_for_Challenge_Notifications_button_up():
	var userID = 'XKwVQ9EqJ7xjEhHoPr0A'
	var all_notifications = yield(get_notification_for_user(userID), 'completed')
	var challengeNotifications = filterChallengeNotification(all_notifications)
	print(challengeNotifications)
	
# For sending notifications to students when new quiz is created
static func send_quiz_notification_to_students(classId, quizId):
	# Get all students in a class
	var classQuery : FirestoreQuery = FirestoreQuery.new()
	classQuery.from('User')
	classQuery.where('classId', FirestoreQuery.OPERATOR.EQUAL, classId)
	var task : FirestoreTask = Firebase.Firestore.query(classQuery)
	var studentList = yield(task, 'task_finished')
	
	var studentIDs = []
	for student in studentList:
		studentIDs.append(student.doc_name)
	
	var notification = {
		'message' : 'You have been assigned a new quiz!',
		'notificationType' : 'new quiz',
		'creationDateTime' : OS.get_datetime(), # gets current datetime in datetime dict format 
		'dataID' : quizId
	}
	
	for student in studentIDs:
		var notificationTask : FirestoreTask
		var notificationCollection : FirestoreCollection = Firebase.Firestore.collection('Notification')
		notification['receiverID'] = student
		notificationTask = notificationCollection.add("", notification)
		yield(notificationTask, "task_finished")
	
	print('Notifications sent to students!')

func _on_New_Quiz_Notification_button_up():
	var classId = 'dummyClass'
	var quizId = 'quiz-quiz-1'
	send_quiz_notification_to_students(classId, quizId)


# When challenge has been completed by challengee, send challenge completed notification back to challenger
static func send_challenge_completed_notification(challengeID, challengeeId):
	# Obtain challenger ID
	var challenge = yield(ChallengeBackend.getChallengeByID(challengeID), 'completed')
	var challengerID = challenge['challengerID']
	
	#Get name and info of challengee
	var userCollection : FirestoreCollection = Firebase.Firestore.collection('User')
	userCollection.get(challengeeId)
	var user : FirestoreDocument = yield(userCollection, 'get_document')
	
	var challengeeName = user.doc_fields.name
	#print(challengeeName)
	var notification = {
		'notificationType' : 'completed challenge',
		'creationDateTime' : OS.get_datetime(), # gets current datetime in datetime dict format
		'receiverID' : challengerID,
		'dataID' : challengeID
	}
	
	var challengeResult = yield(ChallengeBackend.getChallengeResult(challengeID, challengeeId), 'completed')
	#if challengee wins
	if(challengeResult['winnerId'] == user.doc_name):
		notification['message'] = challengeeName + "has won you in a challenge!"
	else:
		notification['message'] = 'You have won ' + challengeeName + " in a challenge!"
	
	#Send notification to challenger
	var notificationCollection : FirestoreCollection = Firebase.Firestore.collection('Notification')
	var task : FirestoreTask
	task = notificationCollection.add('', notification)
	yield(task, "task_finished")
	
	#print('notification sent to challenger')
	
	# Update challengee notification to 'completed challenge'
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Notification')
	query.where("receiverID", FirestoreQuery.OPERATOR.EQUAL, challengeeId, FirestoreQuery.OPERATOR.AND)
	query.where("dataID", FirestoreQuery.OPERATOR.EQUAL, challengeID)
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var challengeeNotification = yield(query_task, "task_finished")
	var notificationId = challengeeNotification[0].doc_name

	var updateNotification : FirestoreTask = notificationCollection.update(notificationId, {'notificationType':"completed challenge"})
	yield(updateNotification, 'task_finished')
	print('Notification sent!')
	
func _on_Send_challenge_completed_notification_button_up():
	var challengeId = "b4JIPytaqNSsDVukEUEi"
	var challengeeId = 'XKwVQ9EqJ7xjEhHoPr0A'
	send_challenge_completed_notification(challengeId, challengeeId)

# When challenge is declined, send notification  to challenger
static func send_challenge_declined_notification(challengeID, challengeeId):
	var challenge = yield(ChallengeBackend.getChallengeByID(challengeID), 'completed')
	var challengerId = challenge.challengerID
	
	# get challengee info
	var userCollection : FirestoreCollection = Firebase.Firestore.collection('User')
	userCollection.get(challengeeId)
	var challengee : FirestoreDocument = yield(userCollection, "get_document")
	var challengeeName = challengee.doc_fields.name
	
	var notification = {
		'message' : challengeeName + ' has declined your challenge.',
		'notificationType' : 'challenge declined',
		'creationDateTime' : OS.get_datetime(), # gets current datetime in datetime dict format 
		'receiverID' : challengerId,
		'dataID' : challengeID
	}
	
	var notificationCollection : FirestoreCollection = Firebase.Firestore.collection('Notification')
	var task : FirestoreTask
	task = notificationCollection.add('', notification)
	yield(task, "task_finished")
	print('Challenge declined')
	
	# Update challengee's notification to 'declined challenge'
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Notification')
	query.where("receiverID", FirestoreQuery.OPERATOR.EQUAL, challengeeId, FirestoreQuery.OPERATOR.AND)
	query.where("dataID", FirestoreQuery.OPERATOR.EQUAL, challengeID)
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var challengeeNotification = yield(query_task, "task_finished")
	var notificationId = challengeeNotification[0].doc_name

	var updateNotification : FirestoreTask = notificationCollection.update(notificationId, {'notificationType':"challenge declined"})
	yield(updateNotification, 'task_finished')
	print('challengee Notification updated!')
	
func _on_Send_challenge_declined_notification2_button_up():
	var challengeId = 'b4JIPytaqNSsDVukEUEi'
	var challengeeId = 'XKwVQ9EqJ7xjEhHoPr0A'
	send_challenge_declined_notification(challengeId, challengeeId)

static func sendChallengeNotification(challengeID):
	# Get challengees
	var challengeCollection : FirestoreCollection = Firebase.Firestore.collection('Challenge')
	challengeCollection.get(challengeID)
	var challenge : FirestoreDocument = yield(challengeCollection, "get_document")
	var challengees = challenge.doc_fields.challengeeID
	
	# Get challenger name
	var userCollection : FirestoreCollection = Firebase.Firestore.collection('User')
	userCollection.get(challenge.doc_fields.challengerID)
	var user : FirestoreDocument = yield(userCollection, "get_document")
	var challengerName = user.doc_fields.name
	
	#Create notification and send notifications to challengees
	var notification ={
		'message' : challengerName + 'has issued you a new challenge!',
		'notificationType' : 'received challenge',
		'dataID' : challengeID,
		'creationDateTime' : OS.get_datetime()
	}
	
	for challengee in challengees:
		notification['receiverID'] = challengee
		var notificationCollection : FirestoreCollection = Firebase.Firestore.collection('Notification')
		var notificationTask : FirestoreTask = notificationCollection.add("", notification)
		yield(notificationTask, "task_finished")
	print('Challenge notifications sent')
	

func _on_Send_challenge_notification_button_up():
	var challengeId = 'b4JIPytaqNSsDVukEUEi'
	sendChallengeNotification(challengeId)


