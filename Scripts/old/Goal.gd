extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var mass = 80

# Returns the gravity that THIS planet exerts on a point
func get_my_gravity_at_point(point : Vector2) -> Vector2:
	var diff = (position - point)
	var grav = diff.normalized() * (mass / diff.length_squared())
	
	# Max grav at 0.1
	if grav.length() > 0.1:
		grav = grav.normalized() * 0.1
	
	return grav



func _on_Goal_body_entered(body):
	if body.is_in_group("Ball"):
		print("YOU WIN")
