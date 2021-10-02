extends Control



func _ready():
	pass # Replace with function body.


# Get all towers available in database. doc_name = towerID
func _on_Get_all_towers_button_up():
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Tower')
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	print(result)


func get_level_for_tower(towerID):
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Level')
	query.where('towerID', FirestoreQuery.OPERATOR.EQUAL, towerID)
	query.order_by('level', FirestoreQuery.DIRECTION.ASCENDING)
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result = yield(query_task, 'task_finished')
	print(result)
	
	
func _on_Get_levels_for_1_tower_button_up():
	get_level_for_tower('fraction-tower')
	pass

func get_questions_by_level(levelID):
	var query : FirestoreQuery = FirestoreQuery.new()
	query.from('Question')
	query.where('levelID', FirestoreQuery.OPERATOR.EQUAL, levelID)
	
	var query_task : FirestoreTask = Firebase.Firestore.query(query)
	var result: Array = yield(query_task, 'task_finished')
	var res:Array = []
	for i in result:
		res.append(i.doc_fields)
	var sm : Array = [1,2,3]
	print(typeof(res))
	
	print(res)
func _on_Get_questions_by_level_button_up():
	get_questions_by_level('dummylevel1')
	pass # Replace with function body.
