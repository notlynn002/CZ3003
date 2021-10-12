extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func read_csv(file_path: String, stop: int = -1, delimiter: String = ",") -> Array:
	var file = File.new()
	file.open(file_path, file.READ)
	var counter: int = 1
	var row: Array
	var rows: Array = []
	file.get_csv_line(delimiter) # skip header
	while !file.eof_reached():
		row = file.get_csv_line(delimiter)
		rows.append(Array(row))
		counter += 1
		if (stop != -1) and (counter == stop):
			break
	file.close()
	return rows
	

func format_question_data(data: Array, tower_prefix: String) -> Dictionary:
	var current_level: int
	var current_question: int
	var question_id: String
	var level_id: String
	var question_fields: Dictionary
	var question_dict: Dictionary = {} 
	for row in data:
		if row[0] != "":
			current_level = int(row[0])
			current_question = 1
		else:
			current_question += 1
		
		level_id = "%s-%02d" % [tower_prefix, current_level]
		
		question_fields = {
			"levelID": level_id,
			"questionBody": row[1],
			"questionOptions": row.slice(2, 5),
			"questionSoln": row[6],
			"questionExplanation": row[7],
			"questionNo": current_question
		}
		
		question_id = "%s-%d" % [level_id, current_question]
		
		question_dict[question_id] = question_fields
	
	return question_dict


func write_questions(questions: Dictionary):
	var collection: FirestoreCollection = Firebase.Firestore.collection("Question")
	var task: FirestoreTask
	for question_id in questions.keys():
		task = collection.update(question_id, questions[question_id])
		yield(task, "task_finished")


func rename_levels(old_level_ids: Array, new_tower_name):
	var collection: FirestoreCollection = Firebase.Firestore.collection("Level")
	var task
	var doc
	var new_tower_id: String = "%s-tower" % new_tower_name
	var new_level_id
	for old_level_id in old_level_ids:
		task = collection.get(old_level_id)
		doc = yield(task, "task_finished")
		doc.doc_fields["level"] = int(doc.doc_fields["level"])
		doc.doc_fields["towerID"] = new_tower_id
		new_level_id = "%s-%02d" % [new_tower_name, doc.doc_fields["level"]]
		task = collection.add(new_level_id, doc.doc_fields)
		yield(task, "task_finished")
		task = collection.delete(old_level_id)
		yield(task, "task_finished")


func rename_questions(old_qn_ids: Array, new_tower_name: String):
	var coll = Firebase.Firestore.collection("Question")
	var task
	var doc
	var old_level_id
	var new_level_id
	var new_qn_id
	for old_qn_id in old_qn_ids:
		task = coll.get(old_qn_id)
		doc = yield(task, "task_finished")
		old_level_id = doc.doc_fields["levelID"]
		new_level_id = "%s-%s" % [new_tower_name, old_level_id.substr(old_level_id.length()-2)]
		doc.doc_fields["levelID"] = new_level_id
		new_qn_id = "%s-%s" % [new_level_id, old_qn_id[old_qn_id.length()-1]]
		task = coll.add(new_qn_id, doc.doc_fields)
		yield(task, "task_finished")
		task = coll.delete(old_qn_id)
		yield(task, "task_finished")

func _on_write_questions_button_up():
	var csv_data = read_csv(
		"C:\\Users\\Glenda\\Desktop\\CZ3003\\Backend\\Data\\QuestionsDB - FourOperations.csv",
		35
		)
	var questions = format_question_data(csv_data, "four-operations")
	yield(write_questions(questions), "completed")
	print("write questions done")


func _on_rename_tower_button_up():
	yield(rename_questions([
		"four-operations-01-1",
		"four-operations-01-2",
		"four-operations-01-3",
		"four-operations-02-1",
		"four-operations-02-2",
		"four-operations-02-3",
		"four-operations-03-1",
		"four-operations-03-2",
		"four-operations-03-3",
		"four-operations-04-1",
		"four-operations-04-2",
		"four-operations-04-3",
		"four-operations-05-1",
		"four-operations-05-2",
		"four-operations-05-3",
		"four-operations-05-4",
		"four-operations-05-5",
		"four-operations-06-1",
		"four-operations-06-2",
		"four-operations-06-3",
		"four-operations-07-1",
		"four-operations-07-2",
		"four-operations-07-3",
		"four-operations-08-1",
		"four-operations-08-2",
		"four-operations-08-3",
		"four-operations-09-1",
		"four-operations-09-2",
		"four-operations-09-3",
		"four-operations-10-1",
		"four-operations-10-2",
		"four-operations-10-3",
		"four-operations-10-4",
		"four-operations-10-5"
		
	], "numbers"), "completed")
	print("done")
