extends Control

class_name ClassBackend

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


static func create_class(teacher_id: String, class_name_: String):
	"""Create a class and write it to the database.
	
	Args:
		teacher_id (String): Teacher ID.
		class_name_ (String): Class name.
	"""
	var class_id: String = class_name_.replace(" ", "-")
	var class_fields: Dictionary = {
		"teacherID": teacher_id,
		"className": class_name_,
		"quizList": []
	}
	var collection: FirestoreCollection = Firebase.Firestore.collection("Class")
	var task: FirestoreTask = collection.add(class_id, class_fields)
	var doc = yield(task, "task_finished")
	if not doc is FirestoreDocument:
		Error.raise_invalid_parameter_error("'%s' is already the name of an existing class." % class_name_)


static func _query_classes(teacher_id: String) -> Array:
	var query: FirestoreQuery = FirestoreQuery.new()
	query.from("Class")
	query.where("teacherID", FirestoreQuery.OPERATOR.EQUAL, teacher_id)
	query.order_by("className")
	var task: FirestoreTask = Firebase.Firestore.query(query)
	return yield(task, "task_finished")


static func get_class_ids(teacher_id: String) -> Array:
	"""Gets the class IDs for a teacher. 
	
	Args:
		teacher_id (string): Teacher ID.
		
	Returns:
		Array[String]: The class IDs as strings. The IDs are ordered according to class name.
		
	"""
	# Query class documents
	var docs: Array = yield(_query_classes(teacher_id), "completed")
	if docs.empty():
		Error.raise_invalid_parameter_error("Either '%s' is not a valid teacher ID or this teacher has no classes" % teacher_id)
		return []
	
	# Extract class ids
	var class_ids: Array = []
	for doc in docs:
		class_ids.append(doc.doc_name)
	return class_ids


static func get_class_names(teacher_id: String) -> Array:
	"""Gets the class names for a teacher. 
	
	Args:
		teacher_id (string): Teacher ID.
		
	Returns:
		Array[String]: The class names as strings. The names are ordered in alphabetical order.
		
	"""
	# Query class documents
	var docs: Array = yield(_query_classes(teacher_id), "completed")
	if docs.empty():
		Error.raise_invalid_parameter_error("Either '%s' is not a valid teacher ID or this teacher has no classes" % teacher_id)
		return []
	
	# Extract class names
	var class_names: Array = []
	for doc in docs:
		class_names.append(doc.doc_fields["className"])
	return class_names
	

static func get_classes(teacher_id: String) -> Array:
	"""Gets the classes and their details for a teacher. 
	
	Args:
		teacher_id (string): Teacher ID.
		
	Returns:
		Array[Dictionary]: The classes as Dictionary objects. 
			Each Dictionary contains following keys-value pairs (all keys are Strings):
					teacherID (String): Teacher ID of the teacher in charge of the class.
					className (String): Class name.
					quizList (Array): Level IDs of the quizzes assigned to the class.
			The objects are ordered according to class name.
	
	Raises:
		ERR_INVALID_PARAMETER: If teacher ID is invalid or the teacher has no classes.
		
	"""
	# Query class documents
	var docs: Array = yield(_query_classes(teacher_id), "completed")
	if docs.empty():
		Error.raise_invalid_parameter_error("Either '%s' is not a valid teacher ID or this teacher has no classes" % teacher_id)
		return []
	
	# Extract class fields
	var classes: Array = []
	for doc in docs:
		classes.append(doc.doc_fields)
	return classes
	

static func delete_class(class_id: String):
	""" Delete a class from the database.
	
	Args:
		class_id (String): Class ID.
	
	"""
	var collection: FirestoreCollection = Firebase.Firestore.collection("Class")
	var task: FirestoreTask = collection.delete(class_id)
	yield(task, "task_finished")
	
	
func _on_test_button_up():
	var error = Error.raise_invalid_parameter_error("test")
	print(error)


func _on_get_classes_button_up():
	var teacher_id: String = "dummyteacher"
	var output = yield(get_classes(teacher_id), "completed")
	print(output)


func _on_add_class_button_up():
	var teacher_id: String = "dummyteacher1"
	for class_name_ in ["Class A", "Class C", "Class D"]:
		yield(create_class(teacher_id, class_name_), "completed")
	yield(create_class("dummyteacher2", "Class B"), "completed")


func _on_delete_class_button_up():
	for class_id in ["GoMgztUAVdjMLzdOZqDK", "GuZdfFqnzz0RBiw6jAkA", "uIiaQ6tIXWY4XXr3EjpG", "wRMIZo7Tdmxnl2eANSJh"]:
		yield(delete_class(class_id), "completed")
