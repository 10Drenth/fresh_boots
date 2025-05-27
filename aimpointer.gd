extends RayCast2D


@onready var line: Line2D = $Line2D
var preview: Node2D
@export var preview_scene: PackedScene
@export var aim_range := 50000.0

func _ready() -> void:
	var n : Node2D = preview_scene.instantiate()
	get_tree().root.add_child.call_deferred(n)
	preview = n
	GameManager.aim_target = preview



func _process(_delta: float) -> void:
	visible = GameManager.aim_state == GameManager.State.AIMING
	if visible:
		target_position = (get_global_mouse_position() * global_transform).normalized() * aim_range
		force_raycast_update()
		if is_colliding() and get_collision_point().distance_to(global_position) > 50 and abs(get_collision_normal().angle_to(Vector2.UP.rotated(global_rotation))) > 0.01:
			line.points = [ position, (get_collision_point() + get_collision_normal() * 6) * global_transform ]
			preview.position = get_collision_point() + get_collision_normal() * 0.01
			preview.rotation = get_collision_normal().angle() + PI * 0.5
			GameManager.aim_target_is_valid = true

		else:
			hide()
			GameManager.aim_target_is_valid = false
	preview.visible = visible
