extends RigidBody2D

var isGrounded = false
#var isMyTurn := true # whether it's this player's turn (turn-mode)
var aimVector
onready var initial_sprite_scale : Vector2 = $Sprite.scale
onready var trajline : Line2D = $TrajectoryLine
onready var trail : Line2D = $Trail
#onready var turnTimer : Timer = $TurnTimer
#onready var postTurnTimer : Timer = $PostTurnTimer

# How long the ball needs to be in contact with one planet to trigger grounded state
const GROUNDED_WAIT_TIME = 0.2

var MAX_STRENGTH = 800
var MIN_STRENGTH = 200
var AIM_DIST_SCALE = 1.8
var LINE_SCALE = 0.5
var TRAIL_LENGTH = 40
#var FLIGHT_TIME := 5.0 # time the ball can fly until turn changes

var GAME
#var game_mode : String # free for all or turns

# Collision bits for gravity areas
var MY_GRAVITY_BIT = 8
var GLOBAL_GRAVITY_BIT = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	$Nametag.set_as_toplevel(true)
#	set_process_input(is_network_master())
	trajline.visible = true
	trail.set_as_toplevel(true)
	GAME = $"../.."

func init(id:int, spawn_point:Vector2, grav_bit:int):
	name = str(id)
	position = spawn_point
	MY_GRAVITY_BIT = grav_bit
#	game_mode = mode
#	if game_mode == "turns":
#		isMyTurn = false

func _process(_delta):
	$Nametag.rect_position = global_position + Vector2(-16, -24)
#	if game_mode == "free-for-all" and self.visible:
#		trail.show()
	trail.visible = self.visible
#	if is_network_master():
	trajline.visible = isGrounded
	aimVector = (get_global_mouse_position() - position) * AIM_DIST_SCALE
	# Clamp
	if aimVector.length() > MAX_STRENGTH:
		aimVector = aimVector.normalized() * MAX_STRENGTH
	elif aimVector.length() < MIN_STRENGTH:
		aimVector = aimVector.normalized() * MIN_STRENGTH
	trajline.points[1] = aimVector * LINE_SCALE
	trajline.global_rotation_degrees = 0
#	if isMyTurn:
#		GAME.rpc_local_unreliable(self, "pup_update_trajline", [trajline.points[1]])
	
	# turn progress bar
#	if !turnTimer.is_stopped():
#		GAME.update_timer(turnTimer.time_left / turnTimer.wait_time)
#		GAME.rpc_local(GAME, "update_timer", [turnTimer.time_left / turnTimer.wait_time])
#	else:
#		if game_mode == "free-for-all":
#			trajline.hide()
#		aimVector = Vector2.ZERO

#puppet func pup_update_trajline(point:Vector2):
#	trajline.points[1] = point
#	trajline.global_rotation_degrees = 0
#	trajline.show()

#puppet func hide_trajline():
#	trajline.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
#	if is_network_master():
	if (Input.is_action_just_pressed("fire") and isGrounded):
		apply_central_impulse(aimVector)
		GAME.log_hit()
#		GAME.rpc_local(GAME, "log_hit", [get_tree().get_network_unique_id()])
		trajline.hide()
#		GAME.rpc_local(self, "hide_trajline")
#		if game_mode == "turns":
#			start_postturn(FLIGHT_TIME)
#			turnTimer.stop()
#	GAME.rpc_local_unreliable(self, "update_state", [global_position, linear_velocity])
#		for id in GAME.players.keys():
#			if id != get_tree().get_network_unique_id():
#				rpc_unreliable_id(id, "update_state", global_position, linear_velocity)
#	else:
#		if goal_position != null:
#			global_position = goal_position
#			linear_velocity = goal_velocity
#			goal_position = null
#			goal_velocity = null
	
	update_trail()

## Called by game instance to start our turn
#func start_turn(dur:float = 10.0):
#	turnTimer.start(dur)
#	isMyTurn = true
#	$Trail.show()
#	trajline.show()
#	GAME.camera.focus = self
#	GAME.rpc_local(self, "pup_start_turn")
#
#func start_postturn(dur:float):
#	isMyTurn = false
#	postTurnTimer.start(dur)
#
#puppet func pup_start_turn():
#	isMyTurn = true
#	$Trail.show()
#	trajline.show()
#	GAME.camera.focus = self
#
#puppet func pup_end_turn():
#	isMyTurn = false
#	$Trail.hide()
#	trajline.hide()

func update_trail():
	trail.add_point(global_position, 0)
	if trail.get_point_count() > TRAIL_LENGTH:
		trail.remove_point(TRAIL_LENGTH)

# Stores latest data from the network until the next physics frame can process it
#var goal_position = null
#var goal_velocity = null
#puppet func update_state(new_position:Vector2, new_velocity:Vector2):
#	goal_position = new_position
#	goal_velocity = new_velocity

func setName(name : String) -> void:
	$Nametag.text = name
func setColor(color : Color) -> void:
	$Sprite.modulate = color
func setSprite(texture : Texture) -> void:
	$Sprite.texture = texture
func setTrail(grad : Gradient) -> void:
	$Trail.gradient = grad

func start_win_animation(dur:float):
#	print("Tweening")
	$Sprite/Tween.interpolate_property($Sprite, "scale",
		null, Vector2.ZERO, dur,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Sprite/Tween.interpolate_property($Sprite, "rotation_degrees",
		$Sprite.rotation_degrees, $Sprite.rotation_degrees + 1280, dur,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	$Sprite/Tween.start()
	# start dampening to help stay in the goal
	linear_damp = 2

func reset_win_animation():
#	print("Untweening")
	$Sprite/Tween.stop_all()
	$Sprite.scale = initial_sprite_scale
	linear_damp = -1

# The goal calls this when the ball collides with it
func on_win():
	# only call from the owner client
#	if is_network_master():
	GAME.on_win()
	# Make self invisible
	self.hide()
	trail.hide()
	trajline.hide()
	$Nametag.hide()
#	GAME.rpc_local(self, "pup_hide_self")
#	start_postturn(0.5)

#puppet func pup_hide_self():
#	self.hide()
#	trail.hide()
#	trajline.hide()
#	$Nametag.hide()

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
		trajline.hide()
#		print("taking off")
		curPlanet.get_node("GravityArea").set_collision_layer_bit(MY_GRAVITY_BIT, false)
		set_collision_mask_bit(GLOBAL_GRAVITY_BIT, true)
		set_collision_mask_bit(MY_GRAVITY_BIT, false)

# We've been on the ground long enough
func _on_Timer_timeout():
#	print("landed")
	isGrounded = true
	# set post-turn timer in turn mode
#	if game_mode == "turns" and !postTurnTimer.is_stopped():
#		postTurnTimer.start(1.0)
	curPlanet.get_node("GravityArea").set_collision_layer_bit(MY_GRAVITY_BIT, true)
	set_collision_mask_bit(GLOBAL_GRAVITY_BIT, false)
	set_collision_mask_bit(MY_GRAVITY_BIT, true)

## Called when a player's turn ends without putting
#func _on_TurnTimer_timeout():
##	print("no hit")
#	start_postturn(0.5)
#	GAME.rpc_local(self, "hide_trajline")

## Change to next player's turn
#func _on_PostTurnTimer_timeout():
##	print("turn end")
#	if game_mode == "turns":
#		GAME.rpc_id(1, 'turn_finished')
#		$Trail.hide()
#		trajline.hide()
#		GAME.rpc_local(self, "pup_end_turn")

