extends StaticBody2D


func _on_area_2d_body_entered(body):
	if body.name == "Player":
		get_tree().change_scene_to_file("res://Levels/level4.tscn")
