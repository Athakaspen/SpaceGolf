extends HSlider


export(NodePath) var nodePath
onready var node = get_node(nodePath)

export(String) var property

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	node.set(property, value)
