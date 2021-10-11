class_name Datetime
""" Class with datetime functions.
"""

static func _unix_to_datetime(unix_time: int) -> Dictionary:
	""" Converts unix time to a datetime Dictionary.
	
	For unknown reasons, the Firebase pluggin is unable to parse datetime Dictionaries from OS.get_datetime_from_unix_time().
	This function is a stand in for that.
	
	Args:
		unix_time (int): Unix time.
	
	Returns:
		Dictionary: Datetime Dictionary.
	
	"""
	var os_datetime: Dictionary = OS.get_datetime_from_unix_time(unix_time)
	return {
		"year": os_datetime["year"],
		"month": os_datetime["month"],
		"day": os_datetime["day"],
		"hour": os_datetime["hour"],
		"minute": os_datetime["minute"],
		"second": os_datetime["second"]
	}


static func get_datetime_dict(year: int, month: int, day: int, hour: int, minute:int, second: int, sgt: bool = false) -> Dictionary:
	""" Get a datetime expressed as a Godot datetime Dictionary.
	
	Args:
		year (int): Year.
		month (int): Month as a number.
		day (int): Day.
		hour (int): Hour as 24-hour time.
		minute (int): Minute.
		second(int): Second.
		sgt (bool, optional): If true, the datetime being passed in is in SGT time. If false, the datetime is in UTC time.
			Default is false.
	
	Returns:
		Dictionary: Datetime in UTC time, expressed as a Godot datetime Dictionary.
		
	"""
	var datetime: Dictionary = {
		"year": year,
		"month": month,
		"day": day,
		"hour": hour,
		"minute": minute,
		"second": second
	}
	if sgt:
		datetime = sgt_to_utc_datetime(datetime)
	return datetime
	
	
static func sgt_to_utc_datetime(datetime: Dictionary) -> Dictionary:
	""" Convert a datetime Dictionary from SGT time to UTC time.
	
	Args:
		datetime (Dictionary): Datetime in SGT time.
		
	Returns:
		Dictionary: Datetime in UTC time.
		
	"""
	var unix_sgt_time: int = OS.get_unix_time_from_datetime(datetime)
	# utc time is 8 hours before sgt time
	var unix_utc_time: int = unix_sgt_time - (8 * 60 * 60)
	var utc_datetime: Dictionary = _unix_to_datetime(unix_utc_time)
	utc_datetime.erase("weekday")
	return utc_datetime
	

static func utc_to_sgt_datetime(datetime: Dictionary) -> Dictionary:
	""" Convert a datetime Dictionary from UTC time to SGT time.
	
	Args:
		datetime (Dictionary): Datetime in UTC time.
		
	Returns:
		Dictionary: Datetime in SGT time.
		
	"""
	var unix_utc_time: int = OS.get_unix_time_from_datetime(datetime)
	# sgt time is 8 hours after utx time
	var unix_sgt_time: int = unix_utc_time + (8 * 60 * 60)
	var sgt_datetime: Dictionary = _unix_to_datetime(unix_sgt_time)
	sgt_datetime.erase("weekday")
	return sgt_datetime


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
