extends CanvasLayer

func _ready():
	$NormalLvlDoorOpen.hide()
	$Qn3/AnsCorrectMsg.hide()
	$Qn3/AnsWrongMsg.hide()
	$Qn3/AnsButton.hide()

#func _on_Qn1_pressed():
#	$PopupMenu.show() # display popup
#	#hide_textbox()
#	#queue_text("what is 1 + 1 = ?")
#	questionCounter += 1
#	#get_tree().change_scene("res://Game Play/NormalLevelQn.tscn")
#
#func _on_Qn2_pressed():
#	if Qn1Answered:
#		$PopupMenu.show() # display popup
#		#hide_textbox()
#		#queue_text("what is 1 + 1 = ?")
#		questionCounter += 1

#func _on_Qn3_pressed():
#	if Qn2Answered:
#		$PopupMenu.show() # display popup
#		#hide_textbox()
#		#queue_text("what is 1 + 1 = ?")
#		questionCounter += 1

#Checking Qn1
func _on_Correct_pressed():
	$Qn3/AnsCorrectMsg.show()
	$Qn3/AnsButton.show()
	$NormalLvlDoorClosed/CollisionShape2D.remove_and_skip()
	$NormalLvlDoorOpen.show()
	
func _on_Wrong_pressed():
	$Qn3/AnsWrongMsg.show()
	$Qn3/AnsButton.show()
	$NormalLvlDoorClosed/CollisionShape2D.remove_and_skip()
	$NormalLvlDoorOpen.show()
	
func _on_Open_Door_pressed():
	var TheRoot = get_node("/root")  #need this as get_node will stop work once you remove your self from the Tree
	var ThisScene = get_node("/root/NormalLevelQn3")

	TheRoot.remove_child(ThisScene)
	ThisScene.call_deferred("free")

	var NextScene = NormalLevelGlobal.prevscene
	TheRoot.add_child(NextScene)

const CHAR_READ_RATE = 0.05

onready var textbox_container = $TextboxContainer
onready var start_symbol = $TextboxContainer/MarginContainer/HBoxContainer/Start
onready var end_symbol = $TextboxContainer/MarginContainer/HBoxContainer/End
onready var label = $TextboxContainer/MarginContainer/HBoxContainer/Label

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var text_queue = []


#func _process(delta):
#	match current_state:
#		State.READY:
#			if !text_queue.empty():
#				display_text()
#		State.READING:
#			if Input.is_action_just_pressed("ui_accept"):
#				label.percent_visible = 1.0
#				$Tween.stop_all()
#				end_symbol.text = "v"
#				change_state(State.FINISHED)
#		State.FINISHED:
#			if Input.is_action_just_pressed("ui_accept"):
#				change_state(State.READY)
#				hide_textbox()

func queue_text(next_text):
	text_queue.push_back(next_text)

func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.hide()

func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()


#func display_text():
#	var next_text = text_queue.pop_front()
#	label.text = next_text
#	label.percent_visible = 0.0
#	change_state(State.READING)
#	show_textbox()
#	$Tween.interpolate_property(label, "percent_visible", 0.0, 1.0, len(next_text) * CHAR_READ_RATE, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	$Tween.start()

func change_state(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Changing state to: State.READY")
		State.READING:
			print("Changing state to: State.READING")
		State.FINISHED:
			print("Changing state to: State.FINISHED")

func _on_Tween_tween_completed(object, key):
	end_symbol.text = "v"
	change_state(State.FINISHED)





