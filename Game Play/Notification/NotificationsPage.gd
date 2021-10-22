extends CanvasLayer


# Declare member variables here. Examples:
export (PackedScene) var Mail


# Called when the node enters the scene tree for the first time.
func _ready():
	
	var notifications = yield(NotificationsBackend.get_notification_for_user(Globals.currUser.userId), "completed")
		
	for i in range(notifications.size()):
		var notif = Mail.instance()
		notif.init(notifications[i]['notificationType'], notifications[i]['message'], notifications[i]['dataID'])
		$ScrollContainer/VBoxContainer.add_child(notif)


func _on_CloseButton_pressed():
	self.queue_free()
