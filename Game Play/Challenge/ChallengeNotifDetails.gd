extends Control


# Declare member variables here. Examples:
var notifType
var notifMsg
var challenge_id
var challengee_id


# Called when the node enters the scene tree for the first time.
func init(nType, nMsg, dataID):
	notifType = nType
	notifMsg = nMsg
	# User is the challenger
	if dataID is Dictionary:
		challenge_id = dataID["challengeID"]
		challengee_id = dataID["challengeeID"]
	# User is the challengee
	else:
		challenge_id = dataID
		challengee_id = Globals.currUser.userId

		
	
func position(x, y):
	self.position(x, y)

func _ready():
	
	if notifType == "received challenge":
		$DetailsButton.hide()
		$ShareButton.hide()
	elif notifType == "completed challenge":
		$AcceptButton.hide()
		$DeclineButton.hide()
		
	$ChallengeDetails.text = notifMsg


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AcceptButton_pressed():
	var arenaPage = preload("res://Game Play/Arena/ArenaPage.tscn").instance()
	arenaPage.init(Globals.currUser.userId, challenge_id, "challenge", true)
	get_tree().get_root().add_child(arenaPage)
	self.queue_free()
	get_node('/root/ChallengeNotifPage').queue_free()


func _on_DeclineButton_pressed():
	NotificationsBackend.send_challenge_declined_notification(challenge_id, Globals.currUser.userId)
	self.queue_free() # stop displaying this notification
	


func _on_DetailsButton_pressed():
	var challenge_result = yield(ChallengeBackend.getChallengeResult(challenge_id, challengee_id), "completed")
	var scene = preload("res://Game Play/Challenge/ChallengeResultsPage.tscn").instance()
	scene.init(challenge_result['winnerName'], challenge_result['loserName'], challenge_result['winnerScore'], challenge_result['loserScore'], challenge_result['winnerTime'], challenge_result['loserTime']) # init root node
	get_tree().get_root().add_child(scene)


func _on_ShareButton_pressed():
	var scene = preload("res://Game Play/Challenge/ShareAchievement.tscn").instance()
	get_tree().get_root().add_child(scene)



	
