tool
extends StaticBody2D

const DENSITY_SCALE = 0.01
export(float, 0.1, 7, 0.1) var density = 1.0;
export(float, 20, 400, 2) var radius = 80.0 setget set_radius
export(float, 0.004, 0.03, 0.001) var falloff = 0.01 setget set_falloff

func set_radius(new_rad):
	# set the var
	radius = new_rad
	# Update the collision and visual
	if Engine.editor_hint:
		update_children()

func set_falloff(new_fo):
	falloff = new_fo
	if Engine.editor_hint:
		update_children()

func update_children():
	$GravityArea.gravity_distance_scale = falloff
	if($PlanetCollisionShape != null):
		$PlanetCollisionShape.shape.radius = radius
		$Sprite.scale = Vector2(1,1) * (0.14/100) * radius
		$GravityArea.gravity = get_mass()

func get_mass(): 
	return PI*radius*radius*DENSITY_SCALE*density

# Called when the node enters the scene tree for the first time.
func _ready():
#	print(radius)
#	print($CollisionShape2D.shape.radius)
#	if Engine.editor_hint:
	$PlanetCollisionShape.shape = CircleShape2D.new()
	update_children()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
