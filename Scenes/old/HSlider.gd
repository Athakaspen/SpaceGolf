extends HSlider


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(NodePath) var ballPath
onready var ball = get_node(ballPath)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _process(delta):
	ball.TEMP_SCALE = value
