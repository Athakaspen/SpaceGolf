extends RigidBody2D

var isGrounded = false
var aimVector
onready var initial_sprite_scale :Vector2 = $Sprite.scale

# How long the ball needs to be in contact with one planet to trigger grounded state
const GROUNDED_WAIT_TIME = 0.2

var MAX_STRENGTH = 700
var MIN_STRENGTH = 200
var AIM_DIST_SCALE = 1.5
var LINE_SCALE = 0.5

var GAME

var MY_GRAVITY_BIT = 8
var GLOBAL_GRAVITY_BIT = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	$Nametag.set_as_toplevel(true)
	set_process_input(is_network_master())
	$TrajectoryLine.visible = is_network_master()
	GAME = $"../.."

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
		GAME.rpc_local_unreliable(self, "update_state", [global_position, linear_velocity])
#		for id in GAME.players.keys():
#			if id != get_tree().get_network_unique_id():
#				rpc_unreliable_id(id, "update_state", global_position, linear_velocity)
	else:
		if goal_position != null:
			global_position = goal_position
			linear_velocity = goal_velocity
			goal_position = null
			goal_velocity = null

# Stores latest data from the network until the next physics frame can process it
var goal_position = null
var goal_velocity = null
puppet func update_state(new_position:Vector2, new_velocity:Vector2):
	goal_position = new_position
	goal_velocity = new_velocity

func setName(name : String) -> void:
	$Nametag.text = name
func setColor(color : Color) -> void:
	$Sprite.modulate = color

func start_win_animation(dur:float):
#	print("Tweening")
	$Sprite/Tween.interpolate_property($Sprite, "scale",
		null, Vector2.ZERO, dur,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Sprite/Tween.interpolate_property($Sprite, "rotation_degrees",
		$Sprite.rotation_degrees, $Sprite.rotation_degrees + 2000, dur,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	$Sprite/Tween.start()

func reset_win_animation():
#	print("Untweening")
	$Sprite/Tween.stop_all()
	$Sprite.scale = initial_sprite_scale
#	print(initial_sprite_scale)

# The goal calls this when the ball collides with it
func on_win():
	# only call from the owner client
	if is_network_master():
		GAME.on_win()
		self.visible = false

# Functions for checking grounded state
var curPlanet
func _on_Area2D_body_entered(body):
	if (body.is_in_group("Planet")):
		curPlanet = body
		$Area2D/Timer.wait_time = GROUNDED_WAIT_TIME
		$Area2D/Timer.start()

func _on_Area2D_body_exited(body):
#	print($Area2D/Timer.time_left)
	$Area2D/Timer.stop()
	if isGrounded == true and curPlanet == body:
		isGrounded = false
#		print("taking off")
		curPlanet.get_node("GravityArea").set_collision_layer_bit(MY_GRAVITY_BIT, false)
		set_collision_mask_bit(GLOBAL_GRAVITY_BIT, true)
		set_collision_mask_bit(MY_GRAVITY_BIT, false)

func _on_Timer_timeout():
#	print("landed")
	isGrounded = true
	curPlanet.get_node("GravityArea").set_collision_layer_bit(MY_GRAVITY_BIT, true)
	set_collision_mask_bit(GLOBAL_GRAVITY_BIT, false)
	set_collision_mask_bit(MY_GRAVITY_BIT, true)
