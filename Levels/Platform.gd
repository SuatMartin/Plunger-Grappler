extends StaticBody2D

@onready var target_position = $TargetPosition

var speed = 50
var pulled = false
var being_plunged = false
var original_pos = null
var moved_to_pos = false
var target_pos = null

func _ready():
	target_pos = target_position.global_position
	original_pos = global_position

func move_to_target_pos():
	get_tree().get_first_node_in_group("player").plunging = false
	get_tree().get_first_node_in_group("plunger").get_parent().release()
	pulled = true
	
	if moved_to_pos == false:
		var tween = create_tween()
		tween.tween_property(self,"global_position",target_pos,1)
		moved_to_pos = true
		await tween.finished
		pulled = false
		being_plunged = false
	else:
		var tween = create_tween()
		tween.tween_property(self,"global_position",original_pos,1)
		moved_to_pos = false
		await tween.finished
		pulled = false
		being_plunged = false
		

func _process(delta):
	if global_position.distance_to(get_tree().get_first_node_in_group("player").global_position) > 400 and being_plunged and not pulled:
		move_to_target_pos()
