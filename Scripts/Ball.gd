extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var isGrounded = false
var aimVector

var MAX_STRENGTH = 700
var MIN_STRENGTH = 200
var AIM_DIST_SCALE = 1.5
var LINE_SCALE = 0.5

var GAME

# Called when the node enters the scene tree for the first time.
func _ready():
	$Nametag.set_as_toplevel(true)
	set_process_input(is_network_master())
	$TrajectoryLine.visible = is_network_master()
	GAME = $"../.."
	pass # Replace with function body.

func _process(_delta):
	$Nametag.rect_position = global_position + Vector2(-16, -24)
	if is_network_master():
		$TrajectoryLine.visible = isGrounded && is_network_master()
		aimVector = (get_global_mouse_position() - position) * AIM_DIST_SCALE
		if aimVector.length() > MAX_STRENGTH:
			aimVector = aimVector.normalized() * MAX_STRENGTH
		elif aimVector.length() < MIN_STRENGTH:
			aimVector = aimVector.normalized() * MIN_STRENGTH
		$TrajectoryLine.points[1] = aimVector * LINE_SCALE
		$TrajectoryLine.global_rotation_degrees = 0
	else:
		aimVector = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if is_network_master():
		if (Input.is_action_just_pressed("fire") and isGrounded):
			apply_central_impulse(aimVector)
		for id in GAME.players.keys():
			if id != get_tree().get_network_unique_id():
				rpc_unreliable_id(id, "update_state", global_position, linear_velocity)
	else:
		if goal_position != null:
			global_position = goal_position
			linear_velocity = goal_velocity
			goal_position = null
			goal_velocity = null

var goal_position = null
var goal_velocity = null
puppet func update_state(new_position:Vector2, new_velocity:Vector2):
	goal_position = new_position
	goal_velocity = new_velocity

func setName(name : String) -> void:
	$Nametag.text = name
func setColor(color : Color) -> void:
	$Sprite.modulate = color

# Functions for checking grounded state
var curPlanet
func _on_Area2D_body_entered(body):
	if (body.is_in_group("Planet")):
		curPlanet = body
		$Area2D/Timer.wait_time = 0.15
		$Area2D/Timer.start()

func _on_Area2D_body_exited(body):
#	print($Area2D/Timer.time_left)
	$Area2D/Timer.stop()
	if isGrounded == true and curPlanet == body:
		isGrounded = false
#		print("taking off")
		curPlanet.get_node("GravityArea").set_collision_layer_bit(3, false)
		set_collision_mask_bit(2, true)
		set_collision_mask_bit(3, false)

func _on_Timer_timeout():
#	print("landed")
	isGrounded = true
	curPlanet.get_node("GravityArea").set_collision_layer_bit(3, true)
	set_collision_mask_bit(2, false)
	set_collision_mask_bit(3, true)
