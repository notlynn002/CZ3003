extends CanvasLayer

# Declare member variables here. Examples:
export (PackedScene) var StudentButton
var selectedTopic

func init(topic):
	selectedTopic = topic

# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide()
	$NoticePopup/TopicLabel.text = "Topic: " + selectedTopic
	
	# loop through class to get students
	for i in 41:
		var sb = StudentButton.instance()
		sb.init(str(i), i) 
		$NoticePopup/ScrollContainer/VBoxContainer.add_child(sb)

func _on_BackButton_pressed():
	get_tree().change_scene("res://Game Play/Challenge/ChallengeTopicPage.tscn")


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon


func _on_ChallengeButton_pressed():
	# randomly selects qns
	# notify challengees
	# navigate to challenge pg
	pass
