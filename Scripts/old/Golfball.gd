extends RigidBody2D

export(bool) var isGravitySareta = true
onready var PlanetsHolder = $"%PlanetsHolder"

var gravScale = 50000.0

const STRENGTH = 700;

var TEMP_SCALE : float = 1.0

# States
enum {FROZEN, GROUNDED, AIR}
var State := AIR
func change_state(new_state) -> void:
	match new_state:
		GROUNDED:
			physics_material_override.absorbent = true
		AIR:
			physics_material_override.absorbent = false
			isGravitySareta = true
		FROZEN:
			isGravitySareta = false
	State = new_state

func _physics_process(_delta):
	
	# Apply Gravity each frame
	if (isGravitySareta):
		var grav = PlanetsHolder.get_gravity_at_point(self.position)
#		self.apply_central_impulse(grav * gravScale)
		self.applied_force = grav * gravScale * mass * TEMP_SCALE
	
#	if (Input.is_action_just_pressed("fire")):
#		apply_central_impulse((get_global_mouse_position() - position).normalized() * STRENGTH)
#		change_state(AIR)
	
	$Line2D.points[1] = linear_velocity * 0.6
	$Line2D.global_rotation_degrees = 0

var prevBodName
# Detect if we're on a planet for good
func _on_Golfball_body_entered(body):
	# only do this in air state
	if State != AIR:
		return
	
	if not $Timer.is_stopped() and body.name == prevBodName:
		print("ope")
		# We've had two collisions in the time limit
#		change_state(GROUNDED)
	else:
		$Timer.start()
		prevBodName = body.name
