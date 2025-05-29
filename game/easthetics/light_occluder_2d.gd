extends LightOccluder2D

func _ready() -> void:
	occluder.polygon = get_parent().polygon
