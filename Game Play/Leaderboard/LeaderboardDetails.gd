extends Control


# Declare member variables here. Examples:
var details

func init(deets):
	details = deets


# Called when the node enters the scene tree for the first time.
func _ready():
	$DetailsLabel.text = details


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
