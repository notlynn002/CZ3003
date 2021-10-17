extends Node

class_name ProfileBackend


static func updateUser(updatedInfo):
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
	var user_collection : FirestoreCollection = Firebase.Firestore.collection("User")
	user_collection.get(id)
	var doc : FirestoreDocument = yield(user_collection, "get_document")
	var chr = doc.doc_fields.character
	return chr
