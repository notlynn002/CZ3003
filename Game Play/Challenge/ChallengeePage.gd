extends CanvasLayer

# Declare member variables here. Examples:
export (PackedScene) var StudentButton
var selectedTopic

func init(topic):
	selectedTopic = topic.to_lower()

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.get_node('ChallengeMusic').play()
	Globals.get('selectedChallengees').clear()
	
	$NoticePopup/TopicLabel.text = "Topic: " + selectedTopic
	
	var classmates = yield(NotificationsBackend.getUserClassmates(Globals.currUser.userId), "completed")
	print(classmates)
	
	# loop through class to get students
	for i in range(classmates.size()):
		var sb = StudentButton.instance()
		sb.init(classmates[i]['studentId'], classmates[i]['studentName'])
		$NoticePopup/ScrollContainer/VBoxContainer.add_child(sb)
	
	$Loading.hide()

func _on_BackButton_pressed():
	get_tree().change_scene("res://Game Play/Challenge/ChallengeTopicPage.tscn")


func _on_ChallengeButton_pressed():
	print(selectedTopic)
	print(Globals.currUser.userId)
	$Loading.show()
	var challengeID = yield(ChallengeBackend.createChallenge(selectedTopic, Globals.currUser.userId, Globals.selectedChallengees), "completed")
	NotificationsBackend.sendChallengeNotification(challengeID)
	var root = get_tree().root
	var arenaPage = preload('res://Game Play/Arena/ArenaPage.tscn').instance()
	arenaPage.init(Globals.currUser.userId, challengeID, 'challenge')
	root.add_child(arenaPage)
	self.queue_free()
	get_node('/root/ChallengeTopicPage').queue_free()
	get_node('/root/ChallengeNotifPage').queue_free()
	

