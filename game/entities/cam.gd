extends Camera2D

func _ready() -> void:
	GameManager.level_init.connect(func(l): l.cameras[name] = self)
