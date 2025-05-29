class_name Player extends CharacterBody2D


const SPEED = 230.0
const EPSILON = 0.001
const JUMP_VELOCITY = -360.0

var has_shoes := true
var facing_right := true
@export var spawning_in := true
@export var push_force := 500

@onready var anim : AnimatedSprite2D = $Sprite2D

var changing_gravity := false
func _ready() -> void:
	PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2.DOWN.rotated(global_transform.get_rotation()))
	var space = get_world_2d().space
	PhysicsServer2D.space_set_param(
		space, PhysicsServer2D.SPACE_PARAM_CONTACT_MAX_ALLOWED_PENETRATION, EPSILON
	)
	anim.frame_changed.connect(step_sound)

func start_spawn() -> void:
	$CPUParticles2D.visible = has_shoes
	if has_shoes:
		anim.play("run_shoes")
	else:
		anim.play("run")
	var tween := create_tween()
	$Sprite2D.position.x = -80
	tween.tween_property($Sprite2D, "position:x", 0, 1.5)
	await tween.finished
	spawning_in = false
	
var was_jumping := false
var landing_timer := 0.0

func _physics_process(delta: float) -> void:
	if spawning_in:
		return
	# Add the gravity.
	# if not is_on_floor():
	velocity += get_gravity() * delta

	# Handle jump.
	var temp_v : Vector2 = velocity.rotated(-rotation)
	if Input.is_action_just_pressed("restart"):
		splat()
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		temp_v.y = JUMP_VELOCITY
		if has_shoes:
			temp_v.y = JUMP_VELOCITY * 0.7
			drop_shoes()

	if Input.is_action_just_pressed("lmb") and has_shoes and GameManager.aim_state == GameManager.State.DEFAULT and not Input.is_action_pressed("cancel_aim"):
		GameManager.set_active_cam("LevelCam")
		GameManager.aim_state = GameManager.State.AIMING
	elif not Input.is_action_pressed("lmb") or Input.is_action_pressed("cancel_aim"):
		if GameManager.aim_state == GameManager.State.AIMING and GameManager.aim_target_is_valid and not Input.is_action_pressed("cancel_aim"):
			GameManager.aim_state = GameManager.State.SHOOTING
			shoot()
		else:
			GameManager.aim_state = GameManager.State.DEFAULT
			GameManager.set_active_cam("PlayerCam")

	var direction := Input.get_axis("ui_left", "ui_right")
	var speed := SPEED
	if has_shoes:
		speed *= 0.5
	elif not is_on_floor():
		speed *= 0.7

	if direction:
		temp_v.x = direction * speed
	else:
		temp_v.x = move_toward(temp_v.x, 0, speed)

	velocity = temp_v.rotated(rotation)
	if facing_right && temp_v.x < - EPSILON:
		facing_right = false
	if not facing_right && temp_v.x > EPSILON:
		facing_right = true
	anim.flip_h = not facing_right

	if changing_gravity:
		return

	if GameManager.level_is_ending:
		velocity = Vector2.ZERO
		return
	var current_anim = anim.animation
	if is_on_floor() and abs(temp_v.x) > EPSILON and not current_anim.contains("run"):
		var was_jumping := current_anim.contains("jump")
		if has_shoes:
			anim.play("run_shoes")
		else:
			anim.play("run")
		if was_jumping:
			anim.frame = 1
			$Audio.play("HeavyStep")
	if is_on_floor() and abs(temp_v.x) <= EPSILON and not current_anim.contains("idle"):
		var was_jumping := current_anim.contains("jump")
		if has_shoes:
			anim.play("idle_shoes")
		else:
			anim.play("idle")
		if was_jumping:
			$Audio.play("HeavyStep")
	if not is_on_floor() and not current_anim.contains("jump"):
		if has_shoes:
			anim.play("jump_shoes")
		else:
			anim.play("jump")


	move_and_slide()

	if not is_on_floor():
		return
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_collider() is RigidBody2D:
			# velocity = velocity.normalized() * max(abs(velocity.length()), abs(col.get_collider().get_velocity().length()))
			col.get_collider().apply_central_impulse(col.get_normal() * -push_force)

func shoot():
	set_physics_process(false)
	PhysicsServer2D.set_active(false)
	var t := GameManager.aim_target.global_transform
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_transform", t, 0.7)
	changing_gravity = true
	$Audio/Zap.play()
	anim.play("jump_shoes")



	await get_tree().create_timer(1.0).timeout
	GameManager.set_active_cam("PlayerCam")
	up_direction = Vector2.UP.rotated(global_transform.get_rotation())
	var new_gravity :=Vector2.DOWN.rotated(global_transform.get_rotation())
	if abs(new_gravity.x) < EPSILON:
		new_gravity.x = 0
	if abs(new_gravity.y) < EPSILON:
		new_gravity.y = 0
	PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, new_gravity)

	set_physics_process(true)
	PhysicsServer2D.set_active(true)
	anim.play("idle_shoes")
	changing_gravity = false
	for n in get_tree().get_nodes_in_group("wakeup"):
		if n is RigidBody2D:
			n.apply_force(Vector2.ZERO)

func drop_shoes() -> void:
	has_shoes = false
	$CPUParticles2D.emitting = false
	$CPUParticles2D.hide()
	GameManager.shoes_dropped.emit(self)

func pickup_shoes() -> void:
	var current_frame = anim.frame
	has_shoes = true
	$CPUParticles2D.emitting = true
	$CPUParticles2D.show()
	anim.play(anim.animation + "_shoes")
	anim.frame = current_frame

@export var splat_scene : PackedScene = load("res://game/player/splat.tscn")

func splat() -> void:
	if GameManager.level_is_ending:
		return
	# GameManager.set_active_cam("LevelCam")
	var cam : Node2D =$PlayerCam
	var remote_transf : RemoteTransform2D = $RemoteTransform2D
	# remote_transf.reparent(get_parent())
	cam.reparent(get_parent())
	# cam.global_transform = global_transform

	if has_shoes:
		drop_shoes()
	GameManager.queue_restart()
	queue_free()
	var n : Node2D = splat_scene.instantiate()
	n.global_transform = global_transform
	get_parent().add_child(n)


func _on_weak_spot_body_entered(body:Node2D) -> void:
	if body.is_in_group("wakeup"):
		splat()

func step_sound():
	if spawning_in or GameManager.level_is_ending:
		return
	if anim.animation.contains("run") and (anim.frame == 1 or anim.frame == 3):
		if has_shoes:
			$Audio.play("HeavyStep")
		else:
			$Audio.play("LightStep")
