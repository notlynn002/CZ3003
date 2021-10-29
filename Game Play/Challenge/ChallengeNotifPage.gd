extends CanvasLayer

export (PackedScene) var Details
export (PackedScene) var Panel


# Declare member variables here. Examples:
var notifications
var challenge_notif = []


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.get_node('ChallengeMusic').play()
	
	notifications = yield(NotificationsBackend.get_notification_for_user(Globals.currUser.userId), "completed")
	for notification in notifications:
		if (notification.notificationType != "new quiz"):
			challenge_notif.append(notification)
	
	# loop through notifications
	for i in range(challenge_notif.size()):
		var notif = Details.instance()
		notif.init(challenge_notif[i]['notificationType'], challenge_notif[i]['message'], challenge_notif[i]['dataID']) # to load from db
		$NoticePopup/ScrollContainer/VBoxContainer.add_child(notif)

	$Loading.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CloseButton_pressed():
	$NoticePopup.hide() # closepopup


func _on_CreateChallengeButton_pressed():
	var root = get_tree().root
	var topicPg = preload("res://Game Play/Challenge/ChallengeTopicPage.tscn").instance()
	root.add_child(topicPg)


func _on_BackButton_pressed():
	# navigate back to previous page
	get_tree().change_scene("res://Game Play/StudentHomePage.tscn")
	self.queue_free()



