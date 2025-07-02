class_name LevelObject extends RefCounted

var offset : Vector2i = Vector2i.ZERO
var shape : Array[Vector2i] = []
var attached_node : Node2D

func to_mask(grid_size: Vector2i) -> BitMap:
	var mask : BitMap =  BitMap.new()
	mask.create(grid_size)
	mark_in_grid(mask)
	return mask


func mark_in_grid(grid: BitMap) -> BitMap:
	for p in shape:
		grid.set_bit(p.x + offset.x, p.y + offset.y, true)
	return grid

func collides_with(grid: BitMap) -> bool:
	for p in shape:
		var true_pos := Vector2i(p.x + offset.x, p.y + offset.y)
		if true_pos.x >= grid.get_size().x or true_pos.x < 0:
			return true
		if true_pos.y >= grid.get_size().y or true_pos.y < 0:
			return true
		if grid.get_bit(true_pos.x, true_pos.y):
			return true
	return false

