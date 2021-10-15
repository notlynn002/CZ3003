extends CanvasLayer


# Declare member variables here. Examples:
export (PackedScene) var Mail


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	# get notifications from db by passing in student ID (Globals.studentID)
	# loop through & display
	
	# demo
	for i in 10:
		if i%2 != 0:
			var notif = Mail.instance()
			notif.init('quiz', 'You have been assigned a quiz.', 'id')
			$ScrollContainer/VBoxContainer.add_child(notif)
		else:
			var notif = Mail.instance()
			notif.init('win', 'You beat Jason in Fraction!', 'id')
			$ScrollContainer/VBoxContainer.add_child(notif)


func _on_CloseButton_pressed():
	self.queue_free()
