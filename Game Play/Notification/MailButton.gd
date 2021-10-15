extends Control


# Declare member variables here. Examples:
var type
var msg
var id

func init(notifType, notifMsg, actionID):
	type = notifType
	msg = notifMsg
	id = actionID

# Called when the node enters the scene tree for the first time.
func _ready():
	$Popup.hide()
	$MailButton/MailMessage.text = msg


func _on_MailButton_pressed():
	print("button pressed")
	if type == 'quiz' or type == 'challenge':
		$Popup/Label.text = 'start ' + type + ' now?'
		$Popup.show()
	elif type == 'win' or type == 'lose':
		# get challenge result from db
		# navigate to challenge results page
		pass
	elif type == 'decline':
		pass


func _on_YesButton_pressed():
	var root = get_tree().root
	var arenaPage = preload('res://Game Play/Arena/ArenaPage.tscn').instance()
	arenaPage.init(Globals.studentID, id, type)
	root.add_child(arenaPage)
	self.queue_free()

func _on_NoButton_pressed():
	$Popup.hide()
