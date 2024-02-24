extends CharacterBody2D

const JUMP_FORCE = 1550			# Force applied on jumping
const MOVE_SPEED = 500			# Speed to walk with
const MAX_SPEED = 2000			# Maximum speed the player is allowed to move
const FRICTION_AIR = 0.95		# The friction while airborne
const FRICTION_GROUND = 0.85	# The friction while on the ground


@export var jog_speed = 300.0
@export var sprint_speed = 600.0
@export var acceleration = 35
@export var deceleration = 50
@export var JUMP_VELOCITY = -550.0
@export var extra_fall_gravity_factor = 1.7
@export var can_double_jump = true
@export var push_force = 200
@export var chain_pull = 500

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 60
var normal_gravity = 0
var fall_gravity = 0
var current_speed = 300
var can_let_go_of_jump = false
var can_jump = true
var left_edge = false
var can_move = true
var can_shoot = true
var is_being_launched = false
var chain_velocity = Vector2.ZERO
var dir_to_launch_point = Vector2.ZERO

var plunging = false
var plunger = null
var rope = null

@onready var variable_jump_timer = %VariableJumpTimer
@onready var coyote_timer = %CoyoteTimer
@onready var ground_check_ray = $GroundCheckRay
@onready var shoot_point = %ShootPoint
@onready var gun_root = $GunRoot
@onready var fire_rate_timer = %FireRateTimer
@onready var aim_ray = $GunRoot/AimRay
@onready var plunger_rope = $PlungerRope
@onready var plunger_launch_timer = $Timers/PlungerLaunchTimer

func _ready():
	rope = get_tree().get_first_node_in_group("rope")
	plunger = get_tree().get_first_node_in_group("plunger")
	
	normal_gravity = gravity
	fall_gravity = gravity * extra_fall_gravity_factor
	current_speed = jog_speed
	
func _input(event: InputEvent) -> void:
	if event is InputEvent:
		if event.is_action_pressed("shoot"):
			if not plunging:
				if aim_ray.is_colliding():
					plunging = true
				# We clicked the mouse -> shoot()
					plunger_rope.shoot(global_position.direction_to(shoot_point.global_position))
				else:
					plunger_rope.shoot(global_position.direction_to(shoot_point.global_position))
					await get_tree().create_timer(.3).timeout
					plunger_rope.release()
			else:
				dir_to_launch_point = global_position.direction_to(plunger.global_position)
				chain_pull = 700
				plunger_launch_timer.start()
				
				plunging = false
				plunger_rope.release()
				is_being_launched = true
				
		if event.is_action_pressed("release"):
			if plunging:
				plunger_rope.release()
				plunging = false
				
		#else:
			## We released the mouse -> release()

func _physics_process(_delta: float) -> void:
	gun_root.look_at(get_global_mouse_position())
	aim_ray.look_at(shoot_point.global_position)
	
	# Walking
	var walk = (Input.get_action_strength("right") - Input.get_action_strength("left")) * MOVE_SPEED

	# Falling
	velocity.y += gravity

	# Hook physics
	if plunger_rope.hooked:
		
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		if global_position.distance_to(plunger_rope.plunger.global_position) > 400:
			chain_pull = 200
			chain_velocity = to_local(plunger_rope.plunger.global_position).normalized() * chain_pull
			if chain_velocity.y > 0:
				# Pulling down isn't as strong
				chain_velocity.y *= 0.55
			else:
				# Pulling up is stronger
				chain_velocity.y *= 1.65
			if sign(chain_velocity.x) != sign(walk):
				# if we are trying to walk in a different
				# direction than the chain is pulling
				# reduce its pull
				chain_velocity.x *= 0.7
		else:
			# Not hooked -> no chain velocity
			chain_pull = 100
			chain_velocity = Vector2(0,0)
	else:
		chain_velocity = Vector2(0,0)
	
	velocity += chain_velocity

	velocity.x += walk		# apply the walking
	move_and_slide()
	velocity.x -= walk		# take away the walk speed again
	# ^ This is done so we don't build up walk speed over time
	
	if is_being_launched:
		velocity += dir_to_launch_point * (chain_pull * 5)

	# Manage friction and refresh jump and stuff
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)	# Make sure we are in our limits
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	var grounded = is_on_floor()
	if grounded:
		velocity.x *= FRICTION_GROUND	# Apply friction only on x (we are not moving on y anyway)
		can_jump = true 				# We refresh our air-jump
		if velocity.y >= 5:		# Keep the y-velocity small such that
			velocity.y = 5		# gravity doesn't make this number huge
	elif is_on_ceiling() and velocity.y <= -5:	# Same on ceilings
		velocity.y = -5

	# Apply air friction
	if !grounded:
		velocity.x *= FRICTION_AIR
		if velocity.y > 0:
			velocity.y *= FRICTION_AIR

	# Jumping
	if Input.is_action_just_pressed("jump"):
		if grounded:
			velocity.y = -JUMP_FORCE	# Apply the jump-force
		elif can_jump:
			can_jump = false	# Used air-jump
			velocity.y = -JUMP_FORCE


func _on_variable_jump_timer_timeout():
	can_let_go_of_jump = true
	pass # Replace with function body.


func _on_coyote_timer_timeout():
	can_jump = false
	pass # Replace with function body.

func _on_fire_rate_timer_timeout():
	can_shoot = true
	pass # Replace with function body.

func _on_plunger_launch_timer_timeout():
	is_being_launched = false
	pass # Replace with function body.
