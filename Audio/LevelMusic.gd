extends CanvasLayer


# Declare member variables here. Examples:
var music_position = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Music.play(music_position)
	$MuteButton.hide()

func _on_PlayButton_pressed():
	music_position = $Music.get_playback_position()
	$Music.stop()
	$PlayButton.hide()
	$MuteButton.show()


func _on_MuteButton_pressed():
	$Music.play(music_position)
	$MuteButton.hide()
	$PlayButton.show()
