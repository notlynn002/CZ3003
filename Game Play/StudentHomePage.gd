extends CanvasLayer

# Declare member variables here. Examples:
var character
var chosen_tower
var classID
var lastLevelAttempted

export (PackedScene) var King
export (PackedScene) var Archer
export (PackedScene) var Huntress
export (PackedScene) var Samurai

var towerBackend = preload("res://Backend/TowerBackend.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.get_node('GenericMusic').play()
	$PopupMenu.hide() # dont showpopup until one of the castle is pressed
	$NewMailButton.hide()
	
	var notifications = yield(NotificationsBackend.get_notification_for_user(Globals.currUser.userId), "completed")
	
	if len(notifications) > 0:
		$NewMailButton.show()
		$MailButton.hide()
		
	# get student's selected character from db
	print("printing from student homepage")
	print(Globals.currUser)
	print(Globals.currUser.userId)
	character = yield(ProfileBackend.getCharacter(Globals.currUser.userId), "completed")
	print(character)
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


func _on_ChallengeButton_pressed():
	var root = get_tree().root
	var challengeNotif = preload("res://Game Play/Challenge/ChallengeNotifPage.tscn").instance()
	root.add_child(challengeNotif)


func _on_MailButton_pressed():
	var root = get_tree().root
	var notifPage = preload('res://Game Play/Notification/NotificationsPage.tscn').instance()
	root.add_child(notifPage)


func _on_LogoutButton_pressed():
	pass # Replace with function body.
	# save state and log out
	# navigate to start page
	get_tree().change_scene("res://Registration Login/StartPage.tscn")


func _on_CreamCastleButton_pressed():
	$PopupMenu/PopUpLabel.text = "Topic:    Ratio" # set label text
	$PopupMenu.show() # display popup
	chosen_tower = "Ratio" # update chosen tower
	var towerIds = yield(towerBackend.get_level_for_tower("ratio-tower"), 'completed')


func _on_WoodCastleButton_pressed():
	$PopupMenu/PopUpLabel.text = "Topic:    Fraction" # set label text
	$PopupMenu.show() # display popup
	chosen_tower = "Fraction" # update chosen tower
	var towerIds = yield(towerBackend.get_level_for_tower("fraction-tower"), 'completed')

func _on_MetalCastleButton_pressed():
	$PopupMenu/PopUpLabel.text = "Topic:    Numbers" # set label text
	$PopupMenu.show() # display popup
	chosen_tower = "Numbers" # update chosen tower
	GlobalArray.nowAtTower = "Numbers"
	var startTower = preload("res://Game Play/Normal Level/NormalLevel.tscn").instance()
	#startTower.init(chosen_tower)


func _on_EnterTowerButton_pressed():
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevel.tscn")
	 # Replace with function body.
	# navigate to inside tower

func _on_ViewLeaderboardButton_pressed():
	var leaderboard = preload("res://Game Play/Leaderboard/LeaderboardPage.tscn").instance()
	leaderboard.init(chosen_tower)
	var Root = get_tree().root
	Root.add_child(leaderboard)


func _on_CloseButton_pressed():
	$PopupMenu.hide() # close popup menu


func _on_NewMailButton_pressed():
	var root = get_tree().root
	var notifPage = preload('res://Game Play/Notification/NotificationsPage.tscn').instance()
	root.add_child(notifPage)
