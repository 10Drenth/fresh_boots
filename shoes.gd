extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

func drop() -> void:
	show()
	$Shoes.flip_h = %Player.anim.flip_h
	$CPUParticles2D.amount = 1
	$CPUParticles2D.amount = 3
	await get_tree().create_timer(0.3).timeout
	$Area2D.monitoring = true
	$CPUParticles2D.emitting = true



func _on_area_2d_body_entered(_body:Node2D) -> void:
	$Area2D.set_deferred("monitoring",false)
	$CPUParticles2D.emitting = false
	hide()
	%Player.pickup_shoes()
