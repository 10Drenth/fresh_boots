extends Node2D

@export var wall_mask : Texture2D
@export var collission_shape_scene: PackedScene

var walls : LevelObject = LevelObject.new()
var physics_objects: Array[LevelObject] = []
@export var gravity_direction := Vector2.DOWN

func _ready() -> void:
	# Instantiate wall object
	var wall_node := $WorldBounds/Walls
	walls.shape = wall_node.occupied_tiles
	walls.attached_node = wall_node
	for pgon : PackedVector2Array in wall_node.shapes:
		for i in range(pgon.size()):
			pgon[i] = pgon[i] * (%LevelData.tile_size as Vector2)
		var n : CollisionPolygon2D = collission_shape_scene.instantiate()
		n.polygon = pgon
		$WorldBounds.add_child(n)
	
	# Physics Objects
	for n : Node2D in get_tree().get_nodes_in_group("physics_objects"):
		var obj := LevelObject.new()
		obj.offset = %LevelData.transform_to_grid(n.transform)
		obj.shape.append(Vector2i.ZERO)
		obj.attached_node = n
		physics_objects.append(obj)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		update_physics_objects()

func update_physics_objects() -> void:
	var sort_by_height := func(o1: LevelObject, o2: LevelObject):
		if gravity_direction.dot(o1.offset) > gravity_direction.dot(o2.offset):
			return true
		return false
	physics_objects.sort_custom(sort_by_height)

	var blank_mask : BitMap = walls.to_mask(%LevelData.grid_size)
	for obj : LevelObject in physics_objects:
		var m := blank_mask.duplicate()
		for other : LevelObject in physics_objects:
			if other == obj:
				continue
			other.mark_in_grid(m)

		while not obj.collides_with(m):
			obj.offset += Vector2i(gravity_direction)
		obj.offset -= Vector2i(gravity_direction)

	for obj : LevelObject in physics_objects:
		obj.attached_node.position = %LevelData.grid_to_world(obj.offset)
