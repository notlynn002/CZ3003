extends CanvasLayer

# Declare member variables here. Examples:
var character
var chosen_tower
export (PackedScene) var King
export (PackedScene) var Archer
export (PackedScene) var Huntress
export (PackedScene) var Samurai


# Called when the node enters the scene tree for the first time.
func _ready():
	$MuteButton.hide() # dont show sound off icon until it is pressed
	$PopupMenu.hide() # dont showpopup until one of the castle is pressed
	# get student's selected characterfrom db
	character = "king" # set as king for now
	if character == "king":
		var king = King.instance() # create an instance of king object
		# initialise starting position on map
		king.position.x = 1008
		king.position.y = 936
		add_child(king) # add king to scene
	elif character == "archer":
		var archer = Archer.instance() # create an instance of archer object
		# initialise starting position on map
		archer.position.x = 1008
		archer.position.y = 936
		add_child(archer) # add archer to scene
	elif character == "huntress":
		var huntress = Huntress.instance() # create an instance of huntress object
		# initialise starting position on map
		huntress.position.x = 1008
		huntress.position.y = 936
		add_child(huntress) # add huntress to scene
	elif character == "samurai":
		var samurai = Samurai.instance() # create an instance of samurai object
		# initialise starting position on map
		samurai.position.x = 1008
		samurai.position.y = 936
		add_child(samurai) # add samurai to scene
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SoundButton_pressed():
	$SoundButton.hide() # stop displaying sound on icon
	# stop playing background music
	$MuteButton.show() # display sound off icon


func _on_MuteButton_pressed():
	$MuteButton.hide() # stop displaying sound off icon
	# starts playing background music
	$SoundButton.show() # display sound on icon


func _on_ChallengeButton_pressed():
	# navigate to challenge page
	get_tree().change_scene("res://Game Play/Challenge/ChallengeNotifPage.tscn")


func _on_MailButton_pressed():
	pass # Replace with function body.
	# navigate to notifications popup


func _on_LogoutButton_pressed():
	pass # Replace with function body.
	# save state and log out
	# navigate to start page
	get_tree().change_scene("res://Registration Login/StartPage.tscn")


func _on_CreamCastleButton_pressed():
	$PopupMenu/PopUpLabel.text = "Topic:    Ratio" # set label text
	$PopupMenu.show() # display popup
	chosen_tower = "Ratio" # update chosen tower


func _on_WoodCastleButton_pressed():
	$PopupMenu/PopUpLabel.text = "Topic:    Fraction" # set label text
	$PopupMenu.show() # display popup
	chosen_tower = "Fraction" # update chosen tower

func _on_MetalCastleButton_pressed():
	$PopupMenu/PopUpLabel.text = "Topic:    Numbers" # set label text
	$PopupMenu.show() # display popup
	chosen_tower = "Numbers" # update chosen tower

func _on_EnterTowerButton_pressed():
	get_tree().change_scene("res://Game Play/NormalLevel.tscn")
	 # Replace with function body.
	# navigate to inside tower

func _on_ViewLeaderboardButton_pressed():
	var leaderboard = preload("res://Game Play/Leaderboard/LeaderboardPage.tscn").instance()
	leaderboard.init(chosen_tower)
	var Root = get_tree().root
	Root.add_child(leaderboard)


func _on_CloseButton_pressed():
	$PopupMenu.hide() # close popup menu
