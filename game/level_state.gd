extends Node2D

var grid_size : Vector2i
@export var wall_mask : Texture2D
@export var tile_size := Vector2i(32, 32)
@export var collission_shape_scene: PackedScene

var state : Dictionary[Vector2i, Tile] = {}
var shapes : Array[PackedVector2Array]

func _ready() -> void:
	if $WorldBounds/Walls and not wall_mask:
		wall_mask = $WorldBounds/Walls.texture
	if not wall_mask:
		print("Missing wall mask!, no worldbounds generated")
		return
	grid_size = wall_mask.get_size() as Vector2i / tile_size
	var mask_image : Image = wall_mask.get_image()
	var mask : BitMap =  BitMap.new()
	mask.create(grid_size)
	# mask.create_from_image_alpha(wall_mask.get_image())
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var tex_probe_pos : Vector2i = tile_size / 2 + tile_size * Vector2i(x, y)
			var is_transparant: bool = mask_image.get_pixelv(tex_probe_pos).a < 0.7
			mask.set_bit(x, y, is_transparant)
			if is_transparant:
				state[Vector2i(x, y)] = WallTile.new()
	shapes = mask.opaque_to_polygons(Rect2(Vector2.ZERO, mask.get_size()), 0.1)
	ResourceSaver.save(mask, "res://bitmasks/base_mask.tres")

	# process shapes
	var flip : Array[bool] = []
	flip.resize(shapes.size())
	flip.fill(true)
	var j := 0
	while j < shapes.size():
		var pgon : PackedVector2Array = Geometry2D.offset_polygon(shapes[j], -0.001)[0]
		var inner_inverted_mask := BitMap.new()
		inner_inverted_mask.resize(grid_size)
		for x in range(grid_size.x):
			for y in range(grid_size.y):
				var b : bool = mask.get_bit(x,y)
				if flip[j]:
					b = not b
				b = b and Geometry2D.is_point_in_polygon(Vector2(x, y), pgon)
				if b:
					print(Vector2i(x, y))
				inner_inverted_mask.set_bit(x, y, b)
		print(inner_inverted_mask.get_true_bit_count())
		if inner_inverted_mask.get_true_bit_count() > 0:

			ResourceSaver.save(inner_inverted_mask, "res://bitmasks/mask_%s.tres" % j)
			var new_shapes := inner_inverted_mask.opaque_to_polygons(Rect2(Vector2.ZERO, grid_size), 0.1)
			print(new_shapes[0])
			var new_flip : Array[bool] = []
			new_flip.resize(new_shapes.size())
			new_flip.fill(not flip[j])
			shapes.append_array(new_shapes)
			flip.append_array(new_flip)

		j += 1


	for pgon : PackedVector2Array in shapes:
		for i in range(pgon.size()):
			pgon[i] = pgon[i] * (tile_size as Vector2)
		var n : CollisionPolygon2D = collission_shape_scene.instantiate()
		n.polygon = pgon
		$WorldBounds.add_child(n)

# func _draw() -> void:
# 	for p in shapes:
# 		draw_polygon(p, [Color.RED])

class Tile extends Node2D:
	var affected_by_gravity := false

class WallTile extends Tile:
	func _init() -> void:
		pass
