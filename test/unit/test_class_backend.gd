extends "res://addons/gut/test.gd"


func before_all():
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")
	
	
func after_all():
	var collection = Firebase.Firestore.collection("Class")
	var task = collection.delete("Test-Class-1")
	yield(task, "task_finished")


func test_create_class():
	var collection = Firebase.Firestore.collection("Class")
	var teacher_id: String = "test-teacher"
	var class_name_: String = "Test Class 1"
	var class_id: String = "Test-Class-1"
	
	# Create class
	yield(ClassBackend.create_class(teacher_id, class_name_), "completed")
	
	# Determine if class exists by retrieving class document
	var task = collection.get(class_id)
	var doc = yield(task, "task_finished")
	
	# Assert that class fields are correct
	var fields: Dictionary = doc.doc_fields
	assert_eq(fields["className"], class_name_)
	assert_true(fields["quizList"].empty())
	assert_eq(fields["teacherID"], teacher_id)


func test_get_class_ids():
	var queried_ids = yield(ClassBackend.get_class_ids("dummyteacher1"), "completed")
	assert_eq(queried_ids, ["Class-A", "Class-C", "Class-D"])
	

func test_get_class_names():
	var queried_names = yield(ClassBackend.get_class_names("dummyteacher1"), "completed")
	assert_eq(queried_names, ["Class A", "Class C", "Class D"])
	

func test_get_classes():
	var class_names = ["Class A", "Class C", "Class D"]
	var teacher_id = "dummyteacher1" 
	var classes = yield(ClassBackend.get_classes(teacher_id), "completed")
	for i in range(class_names.size()):
		assert_eq(classes[i]["className"], class_names[i], "error in _get_classes()")
		assert_eq(classes[i]["teacherID"], teacher_id, "error in _get_classes()")

		



