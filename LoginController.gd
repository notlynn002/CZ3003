extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.connect("login_succeeded", self, "on_FirebaseAuth_login_succeeded")
	Firebase.Auth.connect("login_failed", self, "on_FirebaseAuth_login_failed")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_button_up():
	var email = $email.text
	var password = $password.text
	Firebase.Auth.login_with_email_and_password(email, password)
	


func on_FirebaseAuth_login_succeeded():
	print("success hello there")
	
func on_FirebaseAuth_login_failed(error_code, message):
	print("error_code" + str(error_code))
	print("message" + str(message))



