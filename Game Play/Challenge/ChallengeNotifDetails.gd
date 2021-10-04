extends Control


# Declare member variables here. Examples:
var notifType
var notifMsg
var winner
var loser
var winnerScore
var loserScore
var winnerTime
var loserTime


# Called when the node enters the scene tree for the first time.
func init(nType, nMsg, win, lose, ws, ls, wt, lt):
	notifType = nType
	notifMsg = nMsg
	winner = win
	loser = lose
	winnerScore = ws
	loserScore = ls
	winnerTime = wt
	loserTime = lt
		
	
func position(x, y):
	self.position(x, y)

func _ready():
	
	if notifType == "challenged":
		$DetailsButton.hide()
		$ShareButton.hide()
	elif notifType == "won" or notifType == "lost":
		$AcceptButton.hide()
		$DeclineButton.hide()
		
	$ChallengeDetails.text = notifMsg


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AcceptButton_pressed():
	pass # Replace with function body.
	# navigate to challenge page (aka like normal level page, can reuse)


func _on_DeclineButton_pressed():
	# notify challenger 
	self.queue_free() # stop displaying this notification
	


func _on_DetailsButton_pressed():
	var scene = preload("res://Game Play/Challenge/ChallengeResultsPage.tscn").instance()
	scene.init(winner, loser, winnerScore, loserScore, winnerTime, loserTime) # init root node
	get_tree().get_root().add_child(scene)


func _on_ShareButton_pressed():
	var scene = preload("res://Game Play/Challenge/ShareAchievement.tscn").instance()
	get_tree().get_root().add_child(scene)



	
