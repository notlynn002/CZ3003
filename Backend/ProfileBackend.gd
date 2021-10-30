extends Node

class_name ProfileBackend


static func updateUser(updatedInfo):
	"""Update a user profile.
	
	Args:
		updatedInfo (Dictionary): A dictionary containing the profile fields to be updated.
		
	Returns:
		Dictionary: The updated user profile.
			The profile fields will differ depending on whether the account is a student account or teacher account.
			The profile dictionary for a student account should have the following fields:
				"userId" (String): User ID.
				"email" (String): Account email.
				"character" (String): Account character.
				"classID" (String): Class ID of the student's class.
				"name" (String): Student's name.
				"role" (String):  "student"
			The profile dictionary for a teacher account should have the following fields:
				"userId" (String): User ID.
				"email" (String): Account email.
				"name" (String): Teacher's name.
				"role" (String):  "teacher"
				
	""" 
	var user_collection : FirestoreCollection = Firebase.Firestore.collection("User")
	var update_task : FirestoreTask = user_collection.update(Globals.currUser.userId, updatedInfo)
	var doc : FirestoreDocument = yield(update_task, "task_finished")
	var res = doc.doc_fields
	res["userId"] = doc.doc_name
	Globals.currUser = res
	print(Globals.currUser)
	return res

func _on_updateUser_button_up():
	var updatedInfo = {"name": "studentUpdated", "characterId": 7}
	updateUser(updatedInfo)
	pass # Replace with function body.


static func getUser(id):
	"""Get a user profile
	
	Args:
		id (String): User ID.
		
	Returns:
		Dictionary: The user profile.
			The profile fields will differ depending on whether the account is a student account or teacher account.
			The profile dictionary for a student account should have the following fields:
				"userId" (String): User ID.
				"email" (String): Account email.
				"character" (String): Account character.
				"classID" (String): Class ID of the student's class.
				"name" (String): Student's name.
				"role" (String):  "student"
			The profile dictionary for a teacher account should have the following fields:
				"userId" (String): User ID.
				"email" (String): Account email.
				"name" (String): Teacher's name.
				"role" (String):  "teacher"
				
	""" 
	var user_collection : FirestoreCollection = Firebase.Firestore.collection("User")
	user_collection.get(id)
	var doc : FirestoreDocument = yield(user_collection, "get_document")
	var res = doc.doc_fields
	res["userId"] = doc.doc_name

	return res


func _on_getUser_button_up():
	var id = "abbl6nQirTNVlCBERONJw3cNDd32"
	getUser(id)
	pass # Replace with function body.
	
static func getCharacter(id):
	"""Get a student's account character.
	
	Args:
		id (String): User ID.
		
	Returns:
		String: The account character.
		
	"""
	var user_collection : FirestoreCollection = Firebase.Firestore.collection("User")
	user_collection.get(id)
	var doc : FirestoreDocument = yield(user_collection, "get_document")
	var chr = doc.doc_fields.character
	return chr
