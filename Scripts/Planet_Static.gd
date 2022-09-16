tool
extends StaticBody2D

const DENSITY_SCALE = 0.01
export(float, 0.1, 7, 0.1) var density = 1.0;
export(float, 20, 400, 2) var radius = 80.0 setget set_radius
export(float, 0.004, 0.03, 0.001) var falloff = 0.01 setget set_falloff

export(int, 0, 10) var setSprite = 6 setget set_sprite

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

var sprites = [
	"res://Sprites/Planets/planet00.png",
	"res://Sprites/Planets/planet01.png",
	"res://Sprites/Planets/planet02.png",
	"res://Sprites/Planets/planet03.png",
	"res://Sprites/Planets/planet04.png",
	"res://Sprites/Planets/planet05.png",
	"res://Sprites/Planets/planet06.png",
	"res://Sprites/Planets/planet07.png",
	"res://Sprites/Planets/planet08.png",
	"res://Sprites/Planets/planet09.png",
	"res://Sprites/Planets/planet10.png"
]
func set_sprite(new_val):
	setSprite = new_val
#	if Engine.editor_hint:
	if get_node_or_null("Sprite"):
		$Sprite.texture = load(sprites[new_val])

func update_children():
	$GravityArea.gravity_distance_scale = falloff
	if($PlanetCollisionShape != null):
		$PlanetCollisionShape.shape.radius = radius
		$Sprite.scale = Vector2(1,1) * (0.194/100) * radius
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
	if !Engine.editor_hint:
		set_sprite(setSprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
