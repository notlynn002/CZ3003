extends KinematicBody2D


# Declare member variables here. Examples:
const SPEED = 400
const GRAVITY = 10
const JUMP_POWER = -350
const FLOOR = Vector2(0, -1)

var velocity = Vector2()

var on_ground = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	
func _physics_process(delta):
	# Detect up/down/left/right keystate and only move when pressed.
	if Input.is_action_pressed('ui_right'):
		velocity.x = SPEED
		$AnimatedSprite.play("run")
		$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed('ui_left'):
		velocity.x = -SPEED
		$AnimatedSprite.play("run")
		$AnimatedSprite.flip_h = true
	else:
		velocity.x = 0
		if on_ground == true:
			$AnimatedSprite.play("idle")
		
	if Input.is_action_pressed('ui_up'):
		if on_ground == true:
			velocity.y = JUMP_POWER
			on_ground = false
			
	velocity.y += GRAVITY
	
	if is_on_floor():
		on_ground = true
	else:
		on_ground = false
		if velocity.y < 0:
			$AnimatedSprite.play("jump")
		else:
			$AnimatedSprite.play("idle")	#change to fall once fall animation is added in
	
	velocity = move_and_slide(velocity, FLOOR)
