extends CharacterBody2D

@export var jog_speed = 300.0
@export var sprint_speed = 600.0
@export var acceleration = 35
@export var deceleration = 50
@export var JUMP_VELOCITY = -550.0
@export var extra_fall_gravity_factor = 1.7
@export var can_double_jump = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 1.2
var normal_gravity = 0
var fall_gravity = 0
var current_speed = 300
var can_let_go_of_jump = false
var can_jump = true
var left_edge = false
var can_move = true
var can_shoot = true
var big_shot = false

@onready var variable_jump_timer = %VariableJumpTimer
@onready var coyote_timer = %CoyoteTimer
@onready var ground_check_ray = $GroundCheckRay
@onready var shoot_point = %ShootPoint
@onready var gun_root = $GunRoot
@onready var fire_rate_timer = %FireRateTimer

func _ready():
	normal_gravity = gravity
	fall_gravity = gravity * extra_fall_gravity_factor
	current_speed = jog_speed

func _physics_process(delta):
	gun_root.look_at(get_global_mouse_position())
	
	if ground_check_ray.is_colliding():
		can_jump = true
		left_edge = false
	else:
		if left_edge == false:
			coyote_timer.start()
			left_edge = true
		
	# Add the gravity.
	if not is_on_floor():
		if velocity.y > 0:
			gravity = fall_gravity
		else:
			gravity = normal_gravity
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and can_jump:
		can_let_go_of_jump = false
		variable_jump_timer.start()
		velocity.y = JUMP_VELOCITY
		can_double_jump = false
		
	if Input.is_action_just_released("jump") and !is_on_floor() and can_let_go_of_jump and velocity.y < 0:
		velocity.y = move_toward(velocity.y, 0, 200)
	
	if Input.is_action_just_pressed("shoot") and can_shoot:
		can_shoot = false
		fire_rate_timer.start()
		var dir_to_mouse = global_position.direction_to(shoot_point.global_position).normalized()

		print("bang")
		
	#Handle Sprinting
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed
	if Input.is_action_just_released("sprint"):
		current_speed = jog_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")
	if can_move:
		velocity.x = move_toward(velocity.x,direction * current_speed, acceleration)
	elif !can_move:
		velocity.x = move_toward(velocity.x, 0, 5)
	else:
		velocity.x = move_toward(velocity.x, 0, acceleration)

	move_and_slide()


func _on_variable_jump_timer_timeout():
	can_let_go_of_jump = true
	pass # Replace with function body.


func _on_coyote_timer_timeout():
	can_jump = false
	pass # Replace with function body.

func _on_fire_rate_timer_timeout():
	can_shoot = true
	pass # Replace with function body.
