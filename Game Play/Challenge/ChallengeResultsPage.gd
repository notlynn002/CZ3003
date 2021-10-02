extends CanvasLayer


# Declare member variables here. Examples:
var winner
var loser
var winnerScore
var loserScore
var winnerTime
var loserTime
export (PackedScene) var Result

func init(win, lose, ws, ls, wt, lt):
	winner = win
	loser = lose
	winnerScore = ws
	loserScore = ls
	winnerTime = wt
	loserTime = lt
	

# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide()
	
	var winPlayer = Result.instance()
	winPlayer.init(winner, winnerScore, winnerTime, "winner")
	add_child(winPlayer)
	winPlayer.position = Vector2(100, 100)
	
	var losePlayer = Result.instance()
	losePlayer.init(loser, loserScore, loserTime, "loser")
	add_child(losePlayer)
	losePlayer.position = Vector2(800, 100)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	self.queue_free()


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon
