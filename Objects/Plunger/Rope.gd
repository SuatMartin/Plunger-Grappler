extends Line2D

var player = null
var plunger = null

func _ready():
	visible = false
	player = get_tree().get_first_node_in_group("player")
	plunger = get_tree().get_first_node_in_group("plunger")

func _process(delta):
	if player != null:
		points[0] = player.global_position
		points[1] = plunger.global_position
