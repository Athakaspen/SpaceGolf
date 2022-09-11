tool
extends StaticBody2D

const DENSITY_SCALE = 0.01
export(float, 0.1, 7, 0.1) var density = 1.0;
export(float, 20, 300, 2) var radius = 80.0 setget set_radius

func set_radius(new_rad):
	# set the var
	radius = new_rad
	
	# Update the collision and visual
#	if Engine.editor_hint:
	$CollisionShape2D.shape.radius = new_rad
	$Sprite.scale = Vector2(1,1) * (0.14/100) * new_rad

func get_mass(): 
	return PI*radius*radius*DENSITY_SCALE*density

func _ready():
#	print(radius)
#	print($CollisionShape2D.shape.radius)
#	if Engine.editor_hint:
	$CollisionShape2D.shape = CircleShape2D.new()
	set_radius(radius)

# Returns the gravity that THIS planet exerts on a point
func get_my_gravity_at_point(point : Vector2) -> Vector2:
	var diff = (position - point)
	return diff.normalized() * (get_mass() / diff.length_squared())
