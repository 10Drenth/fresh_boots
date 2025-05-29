extends AnimatedSprite2D


@onready var area : Area2D = $Area2D
@export var start_open : bool = false
var light : PointLight2D = null

func _ready() -> void:
	light = get_node_or_null("PointLight2D")
	if start_open:
		var f = func(): 
			play("opening")
			frame = 7

		f.call_deferred()

var body: CharacterBody2D = null
func _physics_process(delta: float) -> void:
	if body and body.is_on_floor() and not GameManager.level_is_ending:
		GameManager.queue_next_level()
		if body.has_shoes:
			body.get_node("Sprite2D").play("run_shoes")
		else:
			body.get_node("Sprite2D").play("run")
		var tween = create_tween()
		tween.tween_property(body, "global_transform", global_transform, 1.0)
		tween.tween_property(body, "modulate", Color.TRANSPARENT, 0.5)
		await get_tree().create_timer(0.5).timeout
		$GPUParticles2D.emitting = true
		$AudioStreamPlayer.playing = true
		await tween.finished
		play("closing")

func _on_area_2d_body_entered(_body:Node2D) -> void:
	if GameManager.level_is_ending:
		return
	if _body is CharacterBody2D:
		body = _body


func _process(_delta: float) -> void:
	area.monitoring = animation == "opening" and frame >= 7
	if light:
		light.visible = (animation == "opening" and frame >= 7) or (animation == "closing" and frame <= 2)


func _on_pressure_plate_state_changed(pressed:bool) -> void:
	var start_frame := 0
	if animation != "closed":
		start_frame = 9 - frame

	if pressed:
		play("opening")
	else:
		play("closing")
	frame = start_frame




func _on_area_2d_body_exited(_body:Node2D) -> void:
	if _body == body:
		body = null

