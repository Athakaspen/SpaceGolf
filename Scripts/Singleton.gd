extends Node


const DEFAULT_CONNECTION_TYPE = "client"
var network_connection_type = "UNDEFINED"

# Read args from cmd into dict
func parse_os_args():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	return arguments

# Called when the node enters the scene tree for the first time.
func _ready():
	var args = parse_os_args()
	network_connection_type = args.get('network_connection_type', DEFAULT_CONNECTION_TYPE)


#func _input(event):
#	if event.is_action_pressed("reset"):
#		get_tree().reload_current_scene()
