tool
extends StaticBody2D

const DENSITY_SCALE = 0.01
export(float, 0.1, 7, 0.1) var density = 1.0;
export(float, 20, 300, 2) var radius = 80.0 setget set_radius
export(float, 0.004, 0.03, 0.001) var falloff = 0.01 setget set_falloff

func set_radius(new_rad):
	# set the var
	radius = new_rad
	
	# Update the collision and visual
#	if Engine.editor_hint:
	if($PlanetCollisionShape != null):
		$PlanetCollisionShape.shape.radius = new_rad
		$Sprite.scale = Vector2(1,1) * (0.14/100) * new_rad
		$GravityArea.gravity = get_mass()

func set_falloff(new_fo):
	falloff = new_fo
	$GravityArea.gravity_distance_scale = new_fo

func get_mass(): 
	return PI*radius*radius*DENSITY_SCALE*density

# Called when the node enters the scene tree for the first time.
func _ready():
#	print(radius)
#	print($CollisionShape2D.shape.radius)
#	if Engine.editor_hint:
	$PlanetCollisionShape.shape = CircleShape2D.new()
	set_radius(radius)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
