extends Node

const attack_anim = "attack"
const die_anim = "die"
const idle_anim = "idle"
const run_anim = "run"
const take_hit_anim = "take hit"

const loop_animations = [idle_anim, run_anim]
const boss_attack_frame = 3 #from the animation itself, used to sync with the player hit



var next_player_animation = idle_anim
var next_monster_animation = idle_anim

var player_sprite : AnimatedSprite = null
onready var monster_sprite : AnimatedSprite = $"../Monster"

var normal_player_pos = Vector2.ZERO
var middle_player_pos = Vector2.ZERO
var normal_monster_pos = Vector2.ZERO
var middle_monster_pos = Vector2.ZERO

export var player_move_speed = 64.0
export var monster_move_speed = 64.0
export var move_delay = 0.5
onready var tween = $Tween as Tween

func set_player(value : KinematicBody2D):
	player_sprite = value.get_node("AnimatedSprite") as AnimatedSprite
	normal_player_pos = player_sprite.global_position
	middle_player_pos = normal_player_pos
	middle_player_pos.x = $PlayerCenterPosition.position.x
	player_sprite.animation = idle_anim
	player_sprite.playing = true
	player_sprite.connect("animation_finished", self, "_on_player_animation_finished")
	reset_animations(player_sprite)

func _ready():
	normal_monster_pos = monster_sprite.global_position
	middle_monster_pos = normal_monster_pos
	middle_monster_pos.x = $MonsterCenterPosition.position.x
	
	monster_sprite.animation = idle_anim
	reset_animations(monster_sprite)
	pass # Replace with function body.

func action_center_and_back():
	yield(move_to_center(), "completed")
	yield(get_tree().create_timer(2), "timeout")
	yield(move_to_start(), "completed")

func action_player_attack():
	yield(move_to_center(), "completed")
	yield(get_tree().create_timer(move_delay), "timeout")
	yield(player_attack_anim(), "completed")
	yield(get_tree().create_timer(move_delay), "timeout")
	yield(move_to_start(), "completed")

func action_monster_attack():
	yield(move_to_center(), "completed")
	yield(get_tree().create_timer(move_delay), "timeout")
	yield(monster_attack_anim(), "completed")
	yield(get_tree().create_timer(move_delay), "timeout")
	yield(move_to_start(), "completed")

func action_player_kill_monster():
	yield(move_to_center(), "completed")
	yield(get_tree().create_timer(move_delay), "timeout")
	yield(player_kill_monster_anim(), "completed")

func action_monster_kill_player():
	yield(move_to_center(), "completed")
	yield(get_tree().create_timer(move_delay), "timeout")
	yield(monster_kill_player_anim(), "completed")

func move_to_center():
	if tween.is_active():
		yield(tween, "tween_all_completed")
	queue_move_player_to(middle_player_pos)
	queue_move_monster_to(middle_monster_pos)
	tween.start()
	yield(tween, "tween_all_completed")

func move_to_start():
	if tween.is_active():
		yield(tween, "tween_all_completed")
	queue_move_player_to(normal_player_pos)
	queue_move_monster_to(normal_monster_pos)
	tween.start()
	yield(tween, "tween_all_completed")

func player_attack_anim():
	player_sprite.play(attack_anim)
	monster_sprite.play(take_hit_anim)
	next_player_animation = idle_anim
	next_monster_animation = idle_anim
	if player_sprite.animation != next_player_animation:
		yield(player_sprite, "animation_finished")
	
	if monster_sprite.animation != next_monster_animation:
		yield(monster_sprite, "animation_finished")

func monster_attack_anim():
	monster_sprite.play(attack_anim)
	next_player_animation = idle_anim
	next_monster_animation = idle_anim
	
	#Little delay to sync animations
	for i in boss_attack_frame:
		if monster_sprite.animation != next_monster_animation:
			yield(monster_sprite, "frame_changed")
	
	player_sprite.play(take_hit_anim)
	
	if player_sprite.animation != next_player_animation:
		yield(player_sprite, "animation_finished")
	if monster_sprite.animation != next_monster_animation:
		yield(monster_sprite, "animation_finished")

func player_kill_monster_anim():
	player_sprite.play(attack_anim)
	monster_sprite.play(take_hit_anim)
	next_player_animation = idle_anim
	next_monster_animation = die_anim
	
	if monster_sprite.animation != next_monster_animation:
		yield(monster_sprite, "animation_finished")
	next_monster_animation = null
	
	if player_sprite.animation != next_player_animation:
		yield(player_sprite, "animation_finished")

func monster_kill_player_anim():
	monster_sprite.play(attack_anim)
	next_player_animation = die_anim
	next_monster_animation = idle_anim
	#Little delay to sync animations
	for i in boss_attack_frame:
		if monster_sprite.animation != next_monster_animation:
			yield(monster_sprite, "frame_changed")
	player_sprite.play(take_hit_anim)
	
	if player_sprite.animation != next_player_animation:
		yield(player_sprite, "animation_finished")
	next_player_animation = null
	
	if monster_sprite.animation != next_monster_animation:
		yield(monster_sprite, "animation_finished")

func reset_animations(object):
	object.play(idle_anim)
	object.flip_h = false

func queue_move_player_to(position : Vector2):
	var distance = (position.x - player_sprite.position.x)
	player_sprite.flip_h = distance < 0
	player_sprite.play(run_anim)
	var duration = abs(distance/player_move_speed)
	tween.interpolate_property(player_sprite, "global_position", null, position, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

func queue_move_monster_to(position : Vector2):
	var distance = (position.x - monster_sprite.position.x)
	monster_sprite.flip_h = distance > 0
	monster_sprite.play(run_anim)
	var duration = abs(distance/monster_move_speed)
	tween.interpolate_property(monster_sprite, "global_position", null, position, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)

func _on_Tween_tween_completed(object, key):
	if object is AnimatedSprite and key == ":global_position":
		reset_animations(object)	
	pass # Replace with function body.

func _on_player_animation_finished():
	if player_sprite.animation in loop_animations:
		return
	if next_player_animation != null:
		player_sprite.play(next_player_animation)
	else:
		player_sprite.stop()
		player_sprite.frame = player_sprite.frames.get_frame_count(player_sprite.animation) - 1

func _on_Monster_animation_finished():
	if monster_sprite.animation in loop_animations:
		return
	if next_monster_animation != null:
		monster_sprite.play(next_monster_animation)
	else:
		monster_sprite.stop()
		monster_sprite.frame = monster_sprite.frames.get_frame_count(monster_sprite.animation) - 1
