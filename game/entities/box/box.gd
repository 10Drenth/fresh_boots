extends RigidBody2D

@export var lethel_speed := 100

var time_alive := 0.0
func _process(delta: float) -> void:
	time_alive += delta


func _on_body_entered(body:Node) -> void:
	
	if time_alive < 0.5:
		return
	if not GameManager.rumble.get_node("BoxHit").playing:
		GameManager.rumble.get_node("BoxHit").play()
	
	# if body.name == "Player":
	# 	if linear_velocity.length() >= 100:
			#body.splat()
