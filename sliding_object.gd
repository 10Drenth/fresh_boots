extends RigidBody2D



func _on_body_entered(body:Node) -> void:
	print(body.name)
	if body.name == "Player":
		print("check")
