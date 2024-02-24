extends Node2D

@onready var plunger = $Plunger

var direction := Vector2(0,0)	# The direction in which the chain was shot
var plunger_tip := Vector2(0,0)			# The global position the plunger_tip should be in
								# We use an extra var for this, because the chain is 
								# connected to the player and thus all .position
								# properties would get messed with when the player
								# moves.

const SPEED = 50	# The speed with which the chain moves

var flying = false	# Whether the chain is moving through the air
var hooked = false	# Whether the chain has connected to a wall
var player = null
var rope = null
var releasing = false

func _ready():
	rope = get_tree().get_first_node_in_group("rope")
	player = get_tree().get_first_node_in_group("player")

# shoot() shoots the chain in a given direction
func shoot(dir: Vector2) -> void:
	releasing = false
	direction = dir.normalized()	# Normalize the direction and save it
	flying = true					# Keep track of our current scan
	plunger_tip = player.global_position		# reset the plunger_tip position to the player's position
	
	await get_tree().create_timer(.1).timeout
	rope.visible = true

# release() the chain
func release() -> void:
	releasing = true
	
	var tween = create_tween()
	tween.tween_property(plunger,"global_position", player.global_position,.1)
	
	await tween.finished
	rope.visible = false
	flying = false	# Not flying anymore	
	hooked = false	# Not attached anymore

# Every graphics frame we update the visuals
func _process(_delta: float) -> void:
	self.visible = flying or hooked	# Only visible if flying or attached to something
	if not self.visible:
		return	# Not visible -> nothing to draw
	var plunger_tip_loc = to_local(plunger_tip)	# Easier to work in local coordinates
	# We rotate the links (= chain) and the plunger_tip to fit on the line between self.position (= origin = player.position) and the plunger_tip
	#rope.rotation = self.position.angle_to_point(-plunger_tip_loc) - deg_to_rad(90)
	plunger.rotation = self.position.angle_to_point(-plunger_tip_loc) - deg_to_rad(90)

# Every physics frame we update the plunger_tip position
func _physics_process(_delta: float) -> void:
	if not releasing:
		plunger.global_position = plunger_tip	# The player might have moved and thus updated the position of the plunger_tip -> reset it
		if flying:
			# `if move_and_collide()` always moves, but returns true if we did collide
			if plunger.move_and_collide(direction * SPEED):
				hooked = true	# Got something!
				flying = false	# Not flying anymore
		plunger_tip = plunger_tip.move_toward(plunger.global_position,25)	# set `plunger_tip` as starting position for next frame
