extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_FacebookButton_pressed():
	OS.shell_open("https://facebook.com")
	# the above just opens facebook in default web browser
	# need to find plugin and integrate @ backend


func _on_TwitterButton_pressed():
	OS.shell_open("https://twitter.com")
	# the above just opens twitter in default web browser
	# need to find plugin and integrate @ backend


func _on_CloseButton_pressed():
	self.queue_free()
