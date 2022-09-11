tool
extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Returns the gravity vector at the given point
func get_gravity_at_point(point : Vector2) -> Vector2:
	var grav := Vector2.ZERO
	# Sum up gravity vectors from each planet
	for child in get_children():
		if child.has_method('get_my_gravity_at_point'):
			grav += child.get_my_gravity_at_point(point)
	return grav
