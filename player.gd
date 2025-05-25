extends CharacterBody2D


const SPEED = 230.0
const EPSILON = 0.001
const JUMP_VELOCITY = -360.0

var aiming := false
var has_shoes := true
var facing_right := true
@onready var preview: Node2D = %PositionPreview
@onready var world_bounds: Node2D = %WorldBounds
@export var push_force := 500

@onready var anim : AnimatedSprite2D = $Sprite2D

var changing_gravity := false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	var temp_v : Vector2 = velocity.rotated(-rotation)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		temp_v.y = JUMP_VELOCITY
		if has_shoes:
			temp_v.y = JUMP_VELOCITY * 0.7
			drop_shoes()

	if Input.is_action_pressed("lmb") and has_shoes:
		%LevelCam.enabled = true
		%PlayerCam.enabled = false
		aiming = true
	else:
		if aiming and preview.visible:
			shoot()
		aiming = false

	var direction := Input.get_axis("ui_left", "ui_right")
	var speed := SPEED
	if has_shoes:
		speed *= 0.5
	elif not is_on_floor():
		speed *= 0.7

	if direction:
		temp_v.x = direction * speed
	else:
		temp_v.x = move_toward(velocity.x, 0, speed)

	velocity = temp_v.rotated(rotation)
	if facing_right && temp_v.x < - EPSILON:
		facing_right = false
	if not facing_right && temp_v.x > EPSILON:
		facing_right = true
	anim.flip_h = not facing_right

	if changing_gravity:
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
	if is_on_floor() and abs(temp_v.x) <= EPSILON and not current_anim.contains("idle"):
		if has_shoes:
			anim.play("idle_shoes")
		else:
			anim.play("idle")
	if not is_on_floor() and not current_anim.contains("jump"):
		if has_shoes:
			anim.play("jump_shoes")
		else:
			anim.play("jump")

	

	move_and_slide()

	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_collider() is RigidBody2D:
			col.get_collider().apply_central_impulse(col.get_normal() * -push_force)

func shoot():
	set_physics_process(false)
	PhysicsServer2D.set_active(false)
	var t := preview.global_transform
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "global_transform", t, 0.7)
	changing_gravity = true
	anim.play("jump_shoes")



	await get_tree().create_timer(1.0).timeout
	%PlayerCam.enabled = true
	%LevelCam.enabled = false
	up_direction = Vector2.UP.rotated(global_transform.get_rotation())
	PhysicsServer2D.area_set_param(get_viewport().find_world_2d().space, PhysicsServer2D.AREA_PARAM_GRAVITY_VECTOR, Vector2.DOWN.rotated(global_transform.get_rotation()))
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
	%Shoes.global_transform = global_transform
	%Shoes.drop()

func pickup_shoes() -> void:
	var current_frame = anim.frame
	has_shoes = true
	$CPUParticles2D.emitting = true
	anim.play(anim.animation + "_shoes")
	anim.frame = current_frame
