extends Node

enum State {DEFAULT, AIMING, SHOOTING}
signal aim_state_changed(old_state : State, new_state : State)
var aim_state := State.DEFAULT :
	set(value):
		if aim_state != value:
			aim_state = value
			aim_state_changed.emit(aim_state)


var fade : Control
var rumble : AudioStreamPlayer
var _levels : Array[PackedScene] = []
func _ready() -> void:
	var fade_instance = load("res://game/level_management/fade.tscn").instantiate()
	fade = fade_instance.get_node("ColorRect")
	add_child(fade_instance)

	rumble = load("res://game/easthetics/ambience.tscn").instantiate()
	add_child(rumble)

	#load levels
	for i in range(5):
		var s = load("res://levels/level_%s.tscn" % (i + 1))
		if s is PackedScene:
			_levels.append(s)
		else:
			print("error, not a level!")
	var s = load("res://levels/end_scene.tscn")
	if s is PackedScene:
		_levels.append(s)
	clear_fade()

var aim_target : Node2D
var aim_target_is_valid : bool = true

var level_is_ending := false
var _level_index := 0
var level : Level = null
signal level_init(p_level : Level)
func set_level(i: int, p_level: Level) -> void:
	_level_index = i
	level = p_level
	level_init.emit(p_level)

func queue_restart() -> void:
	level_is_ending = true
	await get_tree().create_timer(1.6).timeout
	await fade_to_black()
	get_tree().reload_current_scene()
	clear_fade()
	level_is_ending = false

func queue_next_level() -> void:
	level_is_ending = true
	set_physics_process(false)
	PhysicsServer2D.set_active(false)
	await get_tree().create_timer(2.6).timeout
	await fade_to_black()
	_level_index += 1
	aim_target = null
	get_tree().change_scene_to_packed(_levels[_level_index])

	set_physics_process(true)
	PhysicsServer2D.set_active(true)
	clear_fade()
	level_is_ending = false

func set_active_cam(cam: String) -> void:
	if level and level.cameras.has(cam):
		for k in level.cameras.keys():
			level.cameras[k].enabled = k == cam
	else:
		print("level not init or cam not found %s" % cam)

signal shoes_dropped(p: Player)

func fade_to_black() -> void:
	fade.show()
	fade.modulate = Color.TRANSPARENT
	var tween = create_tween()
	tween.tween_property(fade, "modulate", Color.WHITE, 0.8)
	await tween.finished

func clear_fade() -> void:
	fade.show()
	fade.modulate = Color.WHITE
	var tween = create_tween()
	tween.tween_property(fade, "modulate", Color.TRANSPARENT, 0.35)
