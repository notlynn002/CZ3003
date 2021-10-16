class_name LeaderboardSorter

static func sort_rankings_order(student1, student2):
	
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
