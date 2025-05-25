extends RayCast2D


@onready var line: Line2D = $Line2D
@onready var preview: Node2D = %PositionPreview
@export var aim_range := 50000.0

func _process(_delta: float) -> void:
	visible = get_parent().aiming
	if visible:
		target_position = (get_global_mouse_position() * global_transform).normalized() * aim_range
		force_raycast_update()
		if is_colliding() and get_collision_point().distance_to(global_position) > 50 and abs(get_collision_normal().angle_to(Vector2.UP.rotated(global_rotation))) > 0.01:
			line.points = [ position, (get_collision_point() + get_collision_normal() * 6) * global_transform ]
			preview.position = get_collision_point() + get_collision_normal() * 0.01
			preview.rotation = get_collision_normal().angle() + PI * 0.5

		else:
			hide()
	preview.visible = visible
