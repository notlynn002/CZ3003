extends Node2D


# Declare member variables here. Examples:
var playerName
var score
var time
var playerType

func init(n, s, t, type):
	playerName = n
	score = s
	time = t
	playerType = type

# Called when the node enters the scene tree for the first time.
func _ready():
	if playerType == "loser":
		$WinnerLabel.hide()
		$Trophy.hide()
		
	$NameLabel.text = playerName
	$ScoreLabel.text = "Score: " + str(score) + '/10'
	$TimeLabel.text = 'Time taken: ' + "%d:%02d" % [floor(time / 60), int(time) % 60]
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
