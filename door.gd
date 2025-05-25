extends AnimatedSprite2D


@onready var area : Area2D = $Area2D


func _on_area_2d_body_entered(_body:Node2D) -> void:
	print("Go to next level!")

func _process(delta: float) -> void:
	area.monitoring = animation == "opening" and frame >= 7


func _on_pressure_plate_state_changed(pressed:bool) -> void:
	var start_frame := 0
	if animation != "closed":
		start_frame = 9 - frame

	if pressed:
		play("opening")
	else:
		play("closing")
	frame = start_frame

