extends StaticBody2D

@export var deathParticle : PackedScene
var playerInRange = false

func _on_area_2d_body_entered(body):
	if body.name == "Player":
		playerInRange = true
		modulate = Color(1, 0, 0, 1)
		await get_tree().create_timer(2).timeout
		Kill()
		
func _on_area_2d_body_exited(body):
	if body.name == "Player":
		playerInRange = false
	

func Kill():
	var _particle = deathParticle.instantiate()
	_particle.position = global_position
	_particle.rotation = global_rotation
	_particle.emitting = true
	get_tree().current_scene.add_child(_particle)
	if playerInRange:
		await get_tree().create_timer(.1).timeout
		get_tree().change_scene_to_file("res://Levels/GameOver.tscn")
		
	queue_free()
	



