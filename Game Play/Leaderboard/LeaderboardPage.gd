extends CanvasLayer


# Declare member variables here. Examples:
var details
var tower = 'Fraction'
export (PackedScene) var Details

func init(towerName):
	tower = towerName

	
func repeat_space(count:int):
	print(count)
	var _str = " "
	for i in range(count):
		_str += " "
	return _str

# Called when the node enters the scene tree for the first time.
func _ready():
	$TowerNameLabel.text = tower 
	Globals.get_node('GenericMusic').play()
	
	var results =TowerBackend.get_leaderboard(tower.to_lower()+'-tower')
	
	
	# load from db
	for i in range(results.size()):
		details = str(i+1) + "          " + results[i]['name'] + repeat_space(23 - len(results[i]['name'])) + str(results[i]['highestLevel']) + repeat_space(22 - len(str(results[i]['highestLevel']))) + str(results[i]['totalCorrect']) + repeat_space(30-len(str(results[i]['totalCorrect']))) + "%d:%02d" % [floor(results[i]['timing'] / 60), int(results[i]['timing']) % 60]
#		details = str(i+1) + "          Jacob                  25                     88                             20mins"
		
		var deets = Details.instance()
		deets.init(details)
		$ScrollContainer/VBoxContainer.add_child(deets)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BackButton_pressed():
	self.queue_free()


func _on_HomeButton_pressed():
	get_tree().change_scene("res://Game Play/Normal Level/NormalLevel.tscn")
	self.queue_free()




func _on_FacebookButton_pressed():
	pass # Replace with function body.


func _on_TwitterButton_pressed():
	pass # Replace with function body.
