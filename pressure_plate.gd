extends AnimatedSprite2D


signal state_changed(pressed : bool)
var pressing : int = 0
@export var line_powered_texture : Texture2D
@export var line_unpowered_texture : Texture2D
@onready var power_line : Line2D = $PowerLine

func _on_area_2d_body_entered(_body:Node2D) -> void:
	change_state(true)

func _on_area_2d_body_exited(_body:Node2D) -> void:
	change_state(false)

func change_state(add: bool) -> void:
	var was_pressed : bool = pressing > 0
	if add:
		pressing += 1
	else:
		pressing -= 1
	if pressing > 0 and not was_pressed:
		state_changed.emit(true)
		play("Pressed")
		$AudioStreamPlayer.play()
		power_line.texture = line_powered_texture

	if pressing <= 0 and was_pressed:
		state_changed.emit(false)
		play("UnPressed")
		power_line.texture = line_unpowered_texture
