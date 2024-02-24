extends StaticBody2D

var target_position = Vector2(200, 538) 
var speed = 50  

func _on_CollisionShape2D_body_entered(body):
	if body.is_in_group("Grappler"):
		var direction = (target_position - position).normalized()
		var distance = position.distance_to(target_position)
		if distance > 0.1:
			var movement = direction * speed * get_process_delta_time()
			position += movement
	else:
		position = target_position
