extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


class DatetimeSorter:
	static func _compare_datetime_component(component1: int, component2: int):
		if component1 < component2:
			return true
		elif component1 > component2:
			return false
		else:
			return null
	
	static func sort_ascending(datetime1: Dictionary, datetime2: Dictionary, null_value: bool = false):
		var comparison
		for component in ["year", "month", "day", "hour", "minute", "second"]:
			comparison = _compare_datetime_component(datetime1[component], datetime2[component])
			if comparison != null:
				return comparison 
		# Datetimes are the same 
		if null_value:
			return null
		else: 
			return true
	
	static func sort_descending(datetime1: Dictionary, datetime2: Dictionary):
		var comparison = sort_ascending(datetime1, datetime2, true)
		if comparison != null:
			return not comparison
		else:
			return true
	

class QuizSorter:
	static func sort_chronological(quiz1: Dictionary, quiz2: Dictionary) -> bool:
		var comparison =  DatetimeSorter.sort_ascending(quiz1["publishingDate"], quiz2["publishingDate"], true)
		if comparison != null:
			return comparison
		else:
			if quiz1["quizName"] <= quiz2["quizName"]:
				return true
			else: 
				return false
			
