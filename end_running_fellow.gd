extends Node2D

func _process(delta: float) -> void:
	$Guy.position.x += delta * 50
	$Shoes.position.x += delta * 1.2 * 50
