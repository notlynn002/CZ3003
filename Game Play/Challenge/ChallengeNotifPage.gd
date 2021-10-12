extends CanvasLayer

export (PackedScene) var Details
export (PackedScene) var Panel


# Declare member variables here. Examples:
var classID

func init(class_id):
	classID = class_id


# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide()
	
	# loop through notifications
	for i in 6:
		var notif = Details.instance()
		notif.init("won", "You won Jacob in Fraction challenge!", "You", "Jacob", "8/10", "6/10", "360s", "420s") # to load from db
		$NoticePopup/ScrollContainer/VBoxContainer.add_child(notif)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CloseButton_pressed():
	$NoticePopup.hide() # closepopup


func _on_CreateChallengeButton_pressed():
	var root = get_tree().root
	var topicPg = preload("res://Game Play/Challenge/ChallengeTopicPage.tscn").instance()
	topicPg.init(classID)
	root.add_child(topicPg)


func _on_BackButton_pressed():
	# navigate back to previous page
	get_tree().change_scene("res://Game Play/StudentHomePage.tscn")


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon
