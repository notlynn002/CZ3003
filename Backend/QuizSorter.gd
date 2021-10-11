class_name QuizSorter
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
	var comparison =  Datetime.sort_ascending(quiz1["publishingDate"], quiz2["publishingDate"], true)
	if comparison != null:
		return comparison
	else:
		if quiz1["quizName"] <= quiz2["quizName"]:
			return true
		else: 
			return false
		
