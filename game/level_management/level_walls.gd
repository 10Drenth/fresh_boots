extends Sprite2D

@export var collission_shape_scene: PackedScene
var shapes : Array[PackedVector2Array]
var occupied_tiles : Array[Vector2i] = []

func _ready() -> void:
	var tile_size : Vector2i = %LevelData.tile_size
	var grid_size : Vector2i = texture.get_size() as Vector2i / tile_size
	%LevelData.grid_size = grid_size

	var mask_image : Image = texture.get_image()
	var mask : BitMap =  BitMap.new()
	mask.create(grid_size)
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var tex_probe_pos : Vector2i = tile_size / 2 + tile_size * Vector2i(x, y)
			var is_transparant: bool = mask_image.get_pixelv(tex_probe_pos).a < 0.7
			mask.set_bit(x, y, is_transparant)
			if not is_transparant:
				occupied_tiles.append(Vector2i(x, y))

	shapes = mask.opaque_to_polygons(Rect2(Vector2.ZERO, mask.get_size()), 0.1)

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
				inner_inverted_mask.set_bit(x, y, b)
		print(inner_inverted_mask.get_true_bit_count())
		if inner_inverted_mask.get_true_bit_count() > 0:

			var new_shapes := inner_inverted_mask.opaque_to_polygons(Rect2(Vector2.ZERO, grid_size), 0.1)
			var new_flip : Array[bool] = []
			new_flip.resize(new_shapes.size())
			new_flip.fill(not flip[j])
			shapes.append_array(new_shapes)
			flip.append_array(new_flip)

		j += 1


