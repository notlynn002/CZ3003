extends CanvasLayer


# Declare member variables here. Examples:
var details
var tower = 'Fraction'
export (PackedScene) var Details

func init(towerName):
	tower = towerName


# Called when the node enters the scene tree for the first time.
func _ready():
	$TowerNameLabel.text = tower 
	$MuteButton.hide()
	
	# load from db
	for i in 11:
		details = str(i+1) + "          Jacob                  25                     88                             20mins"
		var deets = Details.instance()
		deets.init(details)
		$ScrollContainer/VBoxContainer.add_child(deets)


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


func _on_HomeButton_pressed():
	pass # Replace with function body.
	# navigate to the many doors page
