class_name NotificationsSorter
""" Sorter class for notifications Dictionaries.
"""


static func sort_latest_first(notification1: Dictionary, notification2: Dictionary) -> bool:
	""" Compares two quiz Dictionaries and checks if they are in chronological order, then alphabetical order.
	
	Args:
		notification1 (Dictionary): A notification Dictionary.
		notification2 (Dictionary): Another notification Dictionary.
	
	Returns:
		bool: True if notification1's publishing date is before notification2's publishing date.
			False if notification1's publishing date is after notification2's publishing date.
	
	"""
	return  Datetime.sort_descending(notification1["creationDateTime"], notification2["creationDateTime"])
		
