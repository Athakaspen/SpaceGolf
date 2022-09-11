extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var isGrounded = false

var STRENGTH = 700

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (Input.is_action_just_pressed("fire")):
		apply_central_impulse((get_global_mouse_position() - position).normalized() * STRENGTH)

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
		print("taking off")
		curPlanet.get_node("GravityArea").set_collision_layer_bit(3, false)
		set_collision_mask_bit(2, true)
		set_collision_mask_bit(3, false)


func _on_Timer_timeout():
	print("landed")
	isGrounded = true
	curPlanet.get_node("GravityArea").set_collision_layer_bit(3, true)
	set_collision_mask_bit(2, false)
	set_collision_mask_bit(3, true)
