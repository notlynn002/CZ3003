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
	$ScoreLabel.text = "Score: " + score
	$TimeLabel.text = "Time taken: " + time
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
