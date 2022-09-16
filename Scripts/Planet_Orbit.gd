tool
extends KinematicBody2D

const DENSITY_SCALE = 0.01
export(float, 0.1, 7, 0.1) var density = 1.0;
export(float, 20, 300, 2) var radius = 80.0 setget set_radius
export(float, 0.004, 0.03, 0.001) var falloff = 0.01 setget set_falloff
export(int, 0, 10) var setSprite = 6 setget set_sprite

export(float, 5, 360, 5) var speed = 70.0
export(float, 10, 500, 10) var dist = 250.0
export var clockwise := true 
export var move_in_editor := false setget set_MIE
export(float, 0, 360, 1) var start_angle = 0.0 setget set_start_angle

onready var parent = $".."
onready var cur_angle = start_angle

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
	if Engine.editor_hint:
		$Sprite.texture = load(sprites[new_val])

func set_start_angle(new_a):
	start_angle = new_a
	self.position = Vector2.UP.rotated(deg2rad(start_angle)) * dist

func set_MIE(val):
	move_in_editor = val
	if val == true: cur_angle = start_angle

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


func _physics_process(delta):
	if !Engine.editor_hint or move_in_editor == true:
		cur_angle += speed * delta * (1 if clockwise else -1)
		self.position = Vector2.UP.rotated(deg2rad(cur_angle)) * dist
