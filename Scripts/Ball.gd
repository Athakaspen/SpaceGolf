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

# Called when the node enters the scene tree for the first time.
func _ready():
	$Nametag.set_as_toplevel(true)
	pass # Replace with function body.

func _process(delta):
	$Label.rect_position = global_position + Vector2(-16, -24)
	$TrajectoryLine.visible = isGrounded
	aimVector = (get_global_mouse_position() - position) * AIM_DIST_SCALE
	if aimVector.length() > MAX_STRENGTH:
		aimVector = aimVector.normalized() * MAX_STRENGTH
	elif aimVector.length() < MIN_STRENGTH:
		aimVector = aimVector.normalized() * MIN_STRENGTH
	$TrajectoryLine.points[1] = aimVector * LINE_SCALE
	$TrajectoryLine.global_rotation_degrees = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (Input.is_action_just_pressed("fire") and isGrounded):
		
		apply_central_impulse(aimVector)

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
