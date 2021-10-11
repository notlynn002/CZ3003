extends Node


var SELECTED_CHALLENGEES = []

func reset():
	SELECTED_CHALLENGEES = []
	
func append(item):
	print("item: " + str(item))
	SELECTED_CHALLENGEES.append(item)
	
func remove(item):
	SELECTED_CHALLENGEES.remove(item)

