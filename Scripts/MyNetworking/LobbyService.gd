extends ViewportContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	set_network_master(1)
	rect_size = OS.window_size
	visible = false;
	pass # Replace with function body.

puppetsync func remove_all_lobbies():
	for child in get_children():
		child.queue_free()

# return data about all active lobbies
func get_lobby_data():
	var data = {}
	for lobby in get_children():
		data[lobby.name] = {
			"name":lobby.nickname,
			"cur_players":lobby.get_cur_players(),
			"max_players":lobby.max_players,
		}
	return data

# format of lobby data
var lobby_dat = {
	"ID": ["name", "cur_players", "max_players"]
}
