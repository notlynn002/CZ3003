extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
		
		
func _on_write_questions_button_up():
	var csv_data = read_csv(
		"C:\\Users\\Glenda\\Desktop\\CZ3003\\Backend\\Data\\QuestionsDB - FourOperations.csv",
		35
		)
	var questions = format_question_data(csv_data, "four-operations")
	yield(write_questions(questions), "completed")
	print("write questions done")
