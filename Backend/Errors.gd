extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var file_name: String = "res://Backend/Errors.gd"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func check_duration(duration: int) -> int:
	if duration < 0:
		return raise_invalid_parameter_error("Time must be greater or equal to 0, not %d" % duration)
	return OK

	
func check_datetime(datetime: Dictionary) -> int:
	"""Checks whether a datetime Dictionary has the correct fields and field values.
	
	Args:
		datetime (Dictionary): Datetime.
	
	Returns:
		int: OK if all fields are valid
	
	Raises:
		ERR_INVALID_PARAMETER: If there is a missing field, or if a field has an invalid value.
	
	"""
	var value1
	var value2
	
	# Check type for fields
	for field in ["day", "hour", "minute", "month", "second", "year"]:
		value1 = datetime.get(field)
		if value1 == null:
			return raise_invalid_parameter_error("'%s' field is missing from datetime" % field)
		elif not value1 is int:
			return raise_invalid_parameter_error("'%s' field of datetime must be an int" % field)
	
	# Check range for minute and second
	for field in ["second", "minute"]:
		value1 = datetime[field]
		if (value1 < 0) or (value1 >= 60):
			return raise_invalid_parameter_error("'%s' field of datetime must be between 0 (inclusive) and 60, not %d" % [field, value1])
	
	# Check range for hour
	value1 = datetime["hour"]
	if (value1 < 0) or (value1 >= 24):
		return raise_invalid_parameter_error("'hour' field of datetime must be between 0 (inclusive) and 24, not %d" % value1)
	
	# Check range for day and month
	value1 = datetime["month"]
	value2 = datetime["day"]
	if value1 == 2:
		if (value2 < 1) or (value2 > 29):
			return raise_invalid_parameter_error("'day' field of datetime must be between 1 and 29 (both inclusive) when 'month' field is 2, not %d" % value2)
	elif value1 in [4, 6, 9, 11]:
		if (value2 < 1) or (value2 > 30):
			return raise_invalid_parameter_error("'day' field of datetime must be between 1 and 30 (both inclusive) when 'month' field is %d, not %d" % [value1, value2])
	else:
		if (value2 < 1) or (value2 > 31):
			return raise_invalid_parameter_error("'day' field of datetime must be between 1 and 31 (both inclusive) when 'month' field is %d, not %d" % [value1, value2])
			
	# Check range for year
	value1 = datetime["year"]
	if value1 <= 0:
		return raise_invalid_parameter_error("'year' field of datetime must be more than 0, not %d" % value1)
			
	return OK


func check_quiz_question(question: Dictionary, complete: bool = true) -> int:
	"""Checks whether a question Dictionary has the correct fields and field values.
	
	Args:
		question (Dictionary): A question.
		complete (bool): If true, a complete check will be run for all question fields.
			If false, the function will not check for 'questionID' and 'levelID'.
	
	Returns:
		int: OK if all fields are valid
	
	Raises:
		ERR_INVALID_PARAMETER: If there is a missing field, a field has an invalid value or there is an invalid field.
	
	"""
	var value
	var string_fields: Array = ["questionID", "levelID", "questionBody", "questionSoln", "questionExplanation"]
	var int_fields: Array = ["questionNo"]
	var optional_fields: Array = ["questionID", "levelID"]
	var all_fields: Array = string_fields + int_fields + ["questionOptions"]
	if not complete:
		for field in optional_fields:
			all_fields.erase(field)
	
	for field in question.keys():
		# Check if field is a valid question field
		if field in all_fields:
			value = question[field]
			
			# Check field type
			if field in string_fields:
				if not value is String:
					return raise_invalid_parameter_error("'%s' field of question must be a String" % field)
			elif field in int_fields:
				if not value is int:
					return raise_invalid_parameter_error("'%s'' field of question must be an int" % field)
			
			# Unique checks	
			if field == "questionOptions":
				if not value is Array:
					return raise_invalid_parameter_error("'questionOptions' field of question must be an Array of Strings")
				else:
					var no_of_options = value.size()
					if no_of_options != 4:
						return raise_invalid_parameter_error("'questionOptions' field of question must have exactly 4 options, not %s" % no_of_options)
					for i in range(no_of_options):
						if not value[i] is String:
							return raise_invalid_parameter_error("In 'questionOptions' field of question, the option at index %d is not a String" % i)
					if not question["questionSoln"] in question["questionOptions"]: 
						return raise_invalid_parameter_error("'questionOptions' field of question must contain the solution '%s'" % question["questionSoln"])		
			
			all_fields.erase(field)
		
		else:
			return raise_invalid_parameter_error("There should not be a '%s' field in question" % field)
	
	# Check for missing fields
	if all_fields:
		return .raise_invalid_parameter_error("'%s' field is missing from question", all_fields[0])
	
	return OK


func check_quiz(quiz: Dictionary, complete = true) -> int:
	"""Checks whether a quiz Dictionary has the correct fields and field values.
	
	Args:
		quiz (Dictionary): A quiz.
	
	Returns:
		int: OK if all fields are valid
	
	Raises:
		ERR_INVALID_PARAMETER: If there is a missing field, a field has an invalid value or there is an invalid field.
	
	"""
	var value
	var string_fields: Array = ["towerID", "levelType", "quizName"]
	var int_fields: Array = ["levelDuration", "attemptNo"]
	var duration_fields: Array = ["levelDuration"]
	var datetime_fields: Array = ["publishingDate"]
	var all_fields: Array = string_fields + int_fields +  datetime_fields + ["questions"]
	
	for field in quiz.keys():
		# Check if field is a valid quiz field
		if field in all_fields:
			value = quiz[field]
			
			# Check field type
			if field in string_fields:
				if not value is String:
					return raise_invalid_parameter_error("'%s' field of quiz must be a String" % field)
			elif field in int_fields:
				if not value is int:
					return raise_invalid_parameter_error("'%s'' field of quiz must be an int" % field)
				if field in duration_fields:
					if check_duration(value) != OK:
						return raise_invalid_parameter_error("'%s'' field of quiz is not in valid duration format" % field)
			elif field in datetime_fields:
				if not value is Dictionary:
					return raise_invalid_parameter_error("'%s' field of quiz must be a datetime Dictionary" % field)
				elif check_datetime(value) != OK:
					return raise_invalid_parameter_error("'%s' field of quiz is not in valid datetime format" % field) 
			
			# Unique checks	
			# Checks for questions
			if field == "questions":
				if not value is Array:
					return raise_invalid_parameter_error("'%s' field of quiz must be an Array of question Dictionaries" % field)
				for i in range(value.size()):
					if not value[i] is Dictionary:
						return raise_invalid_parameter_error("In quiz questions, the question at index %d is not a Dictionary" % i)
					if check_quiz_question(value[i], complete) != OK:
						return raise_invalid_parameter_error("In 'questions', the question at index %d has a missing or invalid field" % i)
			# Checks for attemptNo
			elif field == "attemptNo":
				if not (value > 0):
					return raise_invalid_parameter_error("'%s' must be more than 0, not %d", value)
				
			all_fields.erase(field)
		
		else:
			return $error.raise_invalid_parameter_error("There should not be a '%s' field in question" % field)
	
	# Check for missing fields
	if all_fields:
		return $error.raise_invalid_parameter_error("'%s' field is missing from question", all_fields[0])
	
	return OK


func check_question_attempt(question_attempt: Dictionary) -> int:
	"""Checks whether a question attempt Dictionary has the correct fields and field values.
	
	Args:
		question_attempt (Dictionary): A question attempt.
	
	Returns:
		int: OK if all fields are valid
	
	Raises:
		ERR_INVALID_PARAMETER: If there is a missing field, or if a field has an invalid value.
	
	"""
	# Check questionID
	var value = question_attempt.get("questionID")
	if not value:
		return raise_invalid_parameter_error("'questionID' field is missing from question attempt")
	elif not value is String:
		return raise_invalid_parameter_error("'questionID' field of question attempt must be a String")
	
	# Check best and stuAttemptStatus
	for field in ["best", "stuAttemptStatus"]:
		value = question_attempt.get(field)
		if value == null:
			return raise_invalid_parameter_error("'%s' field is missing from question attempt" % field)
		elif not value is bool:
			return raise_invalid_parameter_error("'%s' field in question attempt must be a bool" % field)
	if check_duration(question_attempt["stuAttemptStatus"]) != OK:
		return raise_invalid_parameter_error("'stuAttemptStatus' field in question has an invalid value")
	
	# Check stuAttemptDuration
	value = question_attempt.get("stuAttemptDuration")
	if value == null:
		return raise_invalid_parameter_error("'stuAttemptDuration' field is missing from question attempt")
	elif not value is int:
		return raise_invalid_parameter_error("'stuAttemptDuration' field in question attempt must be an int")
	
	return OK


func raise_invalid_parameter_error(message: String, backtrack: int = 1) -> int:
	var function: String = "unknown function"
	for caller in get_stack():
		if caller["source"] != file_name:
			function = caller["function"] + "()"
			break
	print ("[Invalid Parameter Error] >> %s: %s" % [function, message])
	return ERR_INVALID_PARAMETER
