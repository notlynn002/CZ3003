class_name LeaderboardSorter
""" Sorter class for lraderboard Dictionaries.
"""

static func sort_rankings_order(student1, student2):
	""" Compares two leaderboard Dictionaries and sorts them according to the highest level, then the total number of questions correct.
	
	Args:
		student1 (Dictionary): A leaderboard Dictionary for a student.
		student2 (Dictionary): A leaderboard Dictionary for another student.
	
	Returns:
		bool: If student1's highest level is greater than student2's highest level, the return value is true.
			If the students have the same highest level and student1's total correct is greater than student2's, the return value is true.
			Otherwise, the return value is false.
	
	"""
	if student1.highestLevel > student2.highestLevel or (student1.highestLevel == student2.highestLevel and student1.totalCorrect > student2.totalCorrect) or (student1.highestLevel == student2.highestLevel and student1.totalCorrect == student2.totalCorrect and student1.timing < student2.timing):
		return true
	
	#elif student1["highestLevel"] < student2["highestLevel"]:
	#	return student2
	
	#if student1.totalCorrect > student2.totalCorrect:
	#	return true
		#elif student1["totalCorrect"] < student2["totalCorrect"]:
		#	return student2
		
	#if student1["timing"] < student2["timing"]:
	#	return true
	return false
