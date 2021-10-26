extends Control

class_name SocialMediaBackend

onready var http= $HTTPRequest

var db_ref: FirebaseDatabaseReference

var fb_app_id = "408168340818896"
var fb_page_id = ""
var fb_login_dict = {
	"app_id": fb_app_id,
	"http": "https://www.facebook.com/v12.0/dialog/oauth?display=popup&",
	"redirect_uri": "https://godotmathgame-c219e.web.app/fb-login.html"
}
var fb_share_dict = {
	"app_id": fb_app_id,
	"http": "https://graph.facebook.com/" + fb_page_id + "/feed?",
	"redirect_uri": ""
}


func _ready():
	Firebase.Auth.connect("login_succeeded", self, "_login_succeeded")
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")
	

func _login_succeeded(arg):
	db_ref = Firebase.Database.get_database_reference("")
	print("logged in!")


func fb_login():
	OS.shell_open(fb_login_dict["http"] + 
		"client_id=" + fb_login_dict["app_id"] + 
		"&redirect_uri=" + fb_login_dict["redirect_uri"] + 
		"&response_type=token")
	
	var response = yield(db_ref, "new_data_update")
	print(response)
	var access_token: String = response["data"]["response"]
	print(access_token)
	print("yayy")
	
	return access_token


func fb_post(access_token, message, link):
	message = message.replace(" ", "%20")
	
	http.request(fb_share_dict["http"] + 
		"access_token=" + access_token + 
		"&message=" + message + 
		"&link=" + link)
	
	var response = yield(http, "request_completed")
	print(response)
	
	return response


func twitter_login():
	pass


func twitter_post(message, link):
	pass


func _on_fb_login_button_up():
	print("testing FB Login")
	fb_login()


func _on_fb_post_button_up():
	print("testing FB Post")
	fb_post("access_token", "Test Post", "google.com")


func _on_twitter_login_button_up():
	print("testing Twitter Login")


func _on_twitter_post_button_up():
	print("testing Twitter Post")
