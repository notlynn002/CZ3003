extends 'res://addons/gut/test.gd'

var AuthBackend = load("res://Backend/AuthBackend.gd")
var StudentLoginPage = load("res://Registration Login/Login/Student Login/StudentLoginPage.tscn")
var TeacherLoginPage = load("res://Registration Login/Login/Teacher Login/TeacherLoginPage.tscn")
var _authBackend = null
var _studentLoginPage = null
var _teacherLoginPage = null

var test_teacher_id = "VYBpzJaF2bbar8VL1gW34YraQLA3"
var teacher_profile_details = {"email":"teachertest@gmail.com", "role": "teacher", "name": "Mr Test Teacher"}
var test_stud_id = "OH4QpydD4fffpN9XY0sNiendqLW2"
var stud_profile_details = {"character": "king", "classID": "Class-A", "email": "studenttest@gmail.com", "name": "John Doe", "role": "student", "approved": false}

func before_all():
	Firebase.Auth.login_with_email_and_password("admin@gmail.com", "cz3003ssad")
	yield(AuthBackend.create_profile(test_teacher_id, teacher_profile_details), "completed")
	
func after_all():
	yield(AuthBackend.delete_profile(test_teacher_id), "completed")
	
func before_each():
	yield(AuthBackend.create_profile(test_stud_id, stud_profile_details), "completed")
	_studentLoginPage = StudentLoginPage.instance()
	Globals.currUser = null

func after_each():
	yield(AuthBackend.delete_profile(test_stud_id), "completed")
	_studentLoginPage.free()
	Globals.currUser = null

func test_teacher_login_as_student():
	_studentLoginPage.email = "teachertest@gmail.com"
	yield(_studentLoginPage._on_FirebaseAuth_login_succeeded({}), "completed")
	assert_eq(_studentLoginPage.error_message,"you are not authorised to log in as a student","teacher should not be able to log in as a student")
	assert_null(Globals.currUser, "global user should not be set")
	
func test_student_login_account_not_approved():
	_studentLoginPage.email = "studenttest@gmail.com"
	yield(_studentLoginPage._on_FirebaseAuth_login_succeeded({}), "completed")
	assert_eq(_studentLoginPage.error_message,"Please wait for the class teacher to approve your account","unapproved student should not be able to login")
	assert_null(Globals.currUser, "global user should not be set")
	
func test_student_login_success():
	_studentLoginPage.email = "studenttest@gmail.com"
	yield(AuthBackend.approveStudent(test_stud_id), "completed")
	yield(_studentLoginPage._on_FirebaseAuth_login_succeeded({}), "completed")
	assert_eq(_studentLoginPage.error_message,"", "no error message displayed when login successful")
	var profile = {"character": "king", "classID": "Class-A", "email": "studenttest@gmail.com", "name": "John Doe", "role": "student", "approved": true, "userId": test_stud_id}
	assert_eq_shallow(Globals.currUser, profile)
	
	
	
	

	
	
	
	
	
	
	
	
