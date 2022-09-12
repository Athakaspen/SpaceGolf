extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var args = parse_os_args()
	match args.get('network_connection_type', NetworkManager.DEFAULT_CONNECTION_TYPE):
		"server":
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://Scenes/MyNetworking/ServerScene.tscn")
		"client":
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://Scenes/MainMenu.tscn")

# Read args from cmd into dict
func parse_os_args():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	return arguments

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
