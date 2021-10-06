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
	""" Sorter class for datetime Dictionaries.
	"""
	
	static func _compare_datetime_component(component1: int, component2: int):
		""" Compares two datetime component ints and checks if they are in ascending order.
		
		Args:
			component1 (int): A datetime component.
			component2 (int): Another datetime component.
		
		Returns:
			bool/null: True if component1 is less than component 2.
				False if component1 is greater than componenet 2.
				Null if they are both equal.
		
		""" 
		if component1 < component2:
			return true
		elif component1 > component2:
			return false
		else:
			return null
	
	static func sort_ascending(datetime1: Dictionary, datetime2: Dictionary, null_value: bool = false):
		""" Compares two datetime Dictionaries and checks if they are in ascending order.
		
		Args:
			datetime1 (Dictionary): A datetime Dictionary.
			datetime2 (Dictionary): Another datetime Dictionary.
			null_value (bool, optional): Determines the value to return if the datetimes are the same.
				If true, return null. If false, return true.
				Default value is false.
		
		Returns:
			bool/null: True if datetime1 is before than datetime2.
				False if datetime1 is after datetime2.
				True or null if they are the same, depending on the value of null_value.
		
		""" 
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
		""" Compares two datetime Dictionaries and checks if they are in descending order.
		
		Args:
			datetime1 (Dictionary): A datetime Dictionary.
			datetime2 (Dictionary): Another datetime Dictionary.
		
		Returns:
			bool: True if datetime1 is before or the same as datetime2.
				False if datetime1 is after datetime2.
		
		""" 
		var comparison = sort_ascending(datetime1, datetime2, true)
		if comparison != null:
			return not comparison
		else:
			return true
	

class QuizSorter:
	""" Sorter class for quiz Dictionaries.
	"""
	
	static func sort_chronological(quiz1: Dictionary, quiz2: Dictionary) -> bool:
		""" Compares two quiz Dictionaries and checks if they are in chronological order, then alphabetical order.
		
		Args:
			quiz1 (Dictionary): A quiz Dictionary.
			quiz2 (Dictionary): Another quiz Dictionary.
		
		Returns:
			bool: True if quiz1's publishing date is before quiz2's publishing date.
				False if quiz1's publishing date is after quiz2's publishing date.
				If the publishing dates are the same, true if the quiz names are in alphabetical order, false otherwise.
		
		"""
		var comparison =  DatetimeSorter.sort_ascending(quiz1["publishingDate"], quiz2["publishingDate"], true)
		if comparison != null:
			return comparison
		else:
			if quiz1["quizName"] <= quiz2["quizName"]:
				return true
			else: 
				return false
			
