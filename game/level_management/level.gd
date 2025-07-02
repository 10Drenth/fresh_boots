class_name Level extends Node2D

# @onready var player := $Player
# @onready var shoes := $Shoes
@export var level_index := 0
@export var starts_with_shoes_on := true
var grid_size : Vector2i
@export var tile_size := Vector2i(32, 32)

var cameras : Dictionary[String, Camera2D]

func _ready() -> void:
	GameManager.set_level(level_index - 1, self)
	# player.has_shoes = starts_with_shoes_on
	# player.get_node("CPUParticles2D").visible = starts_with_shoes_on
	# player.start_spawn()

func transform_to_grid(t: Transform2D) -> Vector2i:
	return (Vector2i(t.origin.ceil())) / tile_size

func grid_to_world(grid_position: Vector2i) -> Vector2:
	return (grid_position * tile_size as Vector2) + 0.5 * tile_size
