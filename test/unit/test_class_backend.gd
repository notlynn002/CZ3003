extends "res://addons/gut/test.gd"

var teacher_id1: String = "test-teacher1"
var teacher_id2: String = "test-teacher2"
var class_name1: String = "Test Class 1"
var class_name2: String = "Test Class 2"
var class_id1: String = "Test-Class-1"
var class_id2: String = "Test-Class-2"


func before_all():
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")
	yield(ClassBackend.create_class(teacher_id1, class_name1), "completed")
	
	
func after_all():
	for class_id in [class_id1, class_id2]:
		yield(ClassBackend.delete_class(class_id), "completed")


func test_create_class():
	var collection = Firebase.Firestore.collection("Class")
	
	# Create class
	yield(ClassBackend.create_class(teacher_id2, class_name2), "completed")
	
	# Determine if class exists by retrieving class document
	var task = collection.get(class_id2)
	var doc = yield(task, "task_finished")
	
	# Assert that class fields are correct
	var fields: Dictionary = doc.doc_fields
	assert_eq(fields["className"], class_name2)
	assert_true(fields["quizList"].empty())
	assert_eq(fields["teacherID"], teacher_id2)


func test_get_class_ids():
	var queried_ids = yield(ClassBackend.get_class_ids(teacher_id1), "completed")
	assert_eq(queried_ids, [class_id1])
	

func test_get_class_names():
	var queried_names = yield(ClassBackend.get_class_names(teacher_id1), "completed")
	assert_eq(queried_names, [class_name1])
	

func test_get_classes():
	var classes = yield(ClassBackend.get_classes(teacher_id1), "completed")
	if not classes is Array:
		fail_test("expected to get array of classes, did not")
	elif classes.size() != 1:
		fail_test("expected to get 1 class, instead got %d" % classes.size())
	else:
		assert_eq(classes[0]["className"], class_name1)
		assert_eq(classes[0]["teacherID"], teacher_id1)

		



