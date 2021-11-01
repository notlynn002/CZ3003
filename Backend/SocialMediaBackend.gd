extends Control

class_name SocialMediaBackend

onready var http= $HTTPRequest

var db_ref: FirebaseDatabaseReference

#var fb_app_id = "408168340818896"
var fb_app_id = '1018849288937440'
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

const SAVE_IMAGE_FILENAME = 'screenshot.png'
const SAVED_IMAGE_PATH = 'res://screenshots/' + SAVE_IMAGE_FILENAME


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
	
func share_on_fb():
	var image = get_viewport().get_texture().get_data()
	yield(get_tree(), 'idle_frame')
	yield(get_tree(), 'idle_frame')
	image.flip_y()
	image.save_png(SAVED_IMAGE_PATH)
	var picture = SAVED_IMAGE_PATH
	var caption = 'I won a challenge!'
	caption = caption.replace(" ", "%20")
#	var access_token = fb_login()
#	print(access_token)
	var access_token = 'GGQVlZAN05STkRsaFdWa0NTTl9PYUNTRmstVGtxSFhjSnhhbFhyMFRUVmpOWFZANZA2NnQVJlRHRYejNNQXhodGFaRHlSb1VUWVF4RW5BWjFQWWQ3N1BnLUdVNlItcjNWMVNnWnpDdjUySThidE9TalNiem95MzNpREZAMSDFEaDNoQThXMmxZAeU45b0lWVlVGUHV5anJ5eV9HbDBmazBsWENqb3pB'
	
	# get page access token
	var page_access_token = OS.shell_open('https://graph.facebook.com/PAGE-ID?fields=access_token&access_token=USER-ACCESS-TOKEN')
	
	OS.shell_open(fb_share_dict["http"] + "app_id=" + fb_app_id + "&picture=" + picture + '&access_token='+ access_token + "&caption=" + caption + "&redirect_uri=" + fb_share_dict["redirect_uri"])


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


func _on_FBShare_pressed():
	share_on_fb()
