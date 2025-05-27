extends Node2D

@export var start_visible := false

func _ready() -> void:
	visible = start_visible
	$Splash1.visible = start_visible
	$Splash2.visible = start_visible
	$Splash3.visible = start_visible
	GameManager.shoes_dropped.connect(drop)
	$Area2D.monitoring = visible

@export var splash1_rotate_speed : float
@export var splash2_rotate_speed : float
func _process(delta: float) -> void:
	$Splash1.rotate(delta * splash1_rotate_speed)
	$Splash2.rotate(delta * splash2_rotate_speed)
	$Splash3.rotate(delta * splash2_rotate_speed*sin(Time.get_ticks_msec() * 0.002))
	$Splash1.scale = Vector2.ONE * (abs(sin(Time.get_ticks_msec() * 0.001)) *0.5 + 0.3)
	$Splash2.scale = Vector2.ONE * (abs(sin(Time.get_ticks_msec()* 0.73 * 0.001)) * 0.5 + 0.3)
	$Splash3.scale = Vector2.ONE * (sin(Time.get_ticks_msec()* 1.16 * 0.001) * 0.5 + 0.3)
	time_since_in_attraction_zone += delta
	if time_since_in_attraction_zone >= 0.7 and p:
		global_position.x = move_toward(global_position.x, p.global_position.x, 1)
		global_position.y = move_toward(global_position.y, p.global_position.y, 1)




func drop(p: Player) -> void:
	global_transform = p.global_transform
	$Shoes.flip_h = p.anim.flip_h
	$CPUParticles2D.emitting = true
	show()
	time_since_in_attraction_zone = 0
	await get_tree().create_timer(0.3).timeout
	$Area2D.monitoring = true



func _on_area_2d_body_entered(_body:Node2D) -> void:
	$Area2D.set_deferred("monitoring",false)
	$CPUParticles2D.emitting = false
	hide()
	if $Splash1.visible:
		$Splash1.hide()
		$Splash2.hide()
		$Splash3.hide()
		GameManager.rumble.get_node("Music").playing = true
	time_since_in_attraction_zone = 0
	_body.pickup_shoes()

var p : CharacterBody2D = null
var time_since_in_attraction_zone := 0.0

func _on_area_2d_2_body_exited(body:Node2D) -> void:
	if p == body:
		p = null

func _on_area_2d_2_body_entered(body:Node2D) -> void:
	p = body
	time_since_in_attraction_zone = 0
