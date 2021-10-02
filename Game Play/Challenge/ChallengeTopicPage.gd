extends CanvasLayer


# Declare member variables here. Examples:
var topic


# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide()
	$NoticePopup/BlackFractionRibbon.hide()
	$NoticePopup/BlackNumbersRibbon.hide()
	$NoticePopup/BlackRatioRibbon.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	get_tree().change_scene("res://Game Play/Challenge/ChallengeNotifPage.tscn")


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon

func _on_ChallengeButton_pressed():
	var Root = get_tree().root
	var challengee = preload("res://Game Play/Challenge/ChallengeePage.tscn").instance()
	#if not topic:
	challengee.init(topic)
	print(topic)
	Root.add_child(challengee)


func _on_RatioRibbon_pressed():
	topic = "Ratio"
	$NoticePopup/BlackFractionRibbon.hide()
	$NoticePopup/BlackNumbersRibbon.hide()
	$NoticePopup/BlackRatioRibbon.show()


func _on_FractionRibbon_pressed():
	topic = "Fraction"
	$NoticePopup/BlackFractionRibbon.show()
	$NoticePopup/BlackNumbersRibbon.hide()
	$NoticePopup/BlackRatioRibbon.hide()


func _on_NumbersRibbon_pressed():
	topic = "Numbers"
	$NoticePopup/BlackFractionRibbon.hide()
	$NoticePopup/BlackNumbersRibbon.show()
	$NoticePopup/BlackRatioRibbon.hide()
	
