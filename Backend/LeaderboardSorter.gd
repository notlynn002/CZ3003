class_name LeaderboardSorter

static func sort_rankings_order(student1, student2):
		if student1["highestLevel"] > student2["highestLevel"]:
			return student1
		elif student1["highestLevel"] < student2["highestLevel"]:
			return student2
		else:
			if student1["totalCorrect"] > student2["totalCorrect"]:
				return student1
			elif student1["totalCorrect"] < student2["totalCorrect"]:
				return student2
			else:
				if student1["timing"] < student2["timing"]:
					return student1
				return student2
