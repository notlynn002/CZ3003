extends CanvasLayer


# Declare member variables here. Examples:
var topic
var classID

func init(class_id):
	classID = class_id

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.get_node('ChallengeMusic').play()
	
	$NoticePopup/BlackFractionRibbon.hide()
	$NoticePopup/BlackNumbersRibbon.hide()
	$NoticePopup/BlackRatioRibbon.hide()


func _on_BackButton_pressed():
	get_tree().change_scene("res://Game Play/Challenge/ChallengeNotifPage.tscn")
	

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
	
