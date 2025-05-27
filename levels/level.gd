class_name Level extends Node2D

@onready var player := $Player
@onready var shoes := $Shoes
@export var level_index := 0
@export var starts_with_shoes_on := true

var cameras : Dictionary[String, Camera2D]

func _ready() -> void:
	GameManager.set_level(level_index - 1, self)
	player.has_shoes = starts_with_shoes_on
	player.get_node("CPUParticles2D").visible = starts_with_shoes_on
	player.start_spawn()


