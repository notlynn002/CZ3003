extends Node

onready var user_functions = $"UserFunctions"
# Called when the node enters the scene tree for the first time.
signal status_changed()
signal iteraion_complete(time)

enum Status {
	WAITING,
	AUTH,
	ERROR
}



var status = Status.WAITING setget set_status
var auth_info
var error_code
var error_message

var email : String
var password : String

var num_iterations : int = 100

onready var firebase = $Firebase

func set_status(value : int):
	status = value
	emit_signal("status_changed")

func _ready() -> void:
	user_functions.connect("login_succeeded", self,"login_succeeded")
	user_functions.connect("login_failed", self,"login_failed")
	firebase.Auth.connect("signup_succeeded", self, "signup_succeeded")
	firebase.Auth.connect("signup_failed", self, "signup_failed")
	pass # Replace with function body.

func start():
	user_functions._login(email, password)
	yield(self, "status_changed")
	match status:
		Status.AUTH:
			pass
		Status.ERROR:
			pass
	pass

func action_sequence():
	pass

func login_succeeded(_auth_info):
	auth_info = _auth_info
	print("login succeeded")
	print(auth_info)
	set_status(Status.AUTH)
	pass

func login_failed(_code, _message):
	error_code = _code
	error_message = _message
	print("login failed")
	print(_code)
	print(_message)
	if _message == "EMAIL_NOT_FOUND":
		sign_up()
	else:
		set_status(Status.ERROR)

func signup_succeeded(_auth_info):
	user_functions._login(email, password)

func signup_failed(_code, _message):
	print("Failed to login and sign up")
	set_status(Status.ERROR)

func sign_up():
	print("trying sign up")
	firebase.Auth.signup_with_email_and_password(email, password)
	pass

func single_iteration() -> float:
	firebase.Firestore._set_offline(false)
	var start = OS.get_ticks_msec()
	var all_towers : Array = yield(user_functions.get_all_towers(), "completed")
#	print(all_towers)
	var chosen_tower = "numbers-tower" #all_towers[randi()%all_towers.size()]
#	print(chosen_tower)
	firebase.Firestore._set_offline(false)
	var levels = yield(user_functions.get_level_for_tower(chosen_tower), "completed")
	var chosen_level = levels[randi()%levels.size()]
	print(levels)
#	print(chosen_level)
	firebase.Firestore._set_offline(false)
	var questions = yield(user_functions.get_questions_by_level(chosen_level), "completed")
	print(questions)
	var end = OS.get_ticks_msec()
#	print(end - start)
	return end - start

func run():
	if status == Status.AUTH:
		for i in num_iterations:
			firebase.Firestore._set_offline(false)
			var time = yield(single_iteration(), "completed")
			emit_signal("iteraion_complete", time)
		$"../VBoxContainer/ColorRect".color = Color.cyan
	get_parent().emit_signal("finished", get_parent().id, get_parent().times)
