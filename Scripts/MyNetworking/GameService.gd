extends ViewportContainer

var GAME_INSTANCE = preload("res://Scenes/MyNetworking/GameInstance.tscn")
var OFFLINE_GAME_INSTANCE = preload("res://Scenes/MyNetworking/GameInstance_Offline.tscn")

var HOLE_SEQUENCES = {
	"default":[
		"res://Scenes/Holes/Hole1.tscn",
		"res://Scenes/Holes/Hole2.tscn",
		"res://Scenes/Holes/Hole3.tscn",
		"res://Scenes/Holes/Hole4.tscn",
		"res://Scenes/Holes/Hole5.tscn",
		"res://Scenes/Holes/Hole6.tscn"
	]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	set_network_master(1)
	rect_size = OS.window_size
	visible = false
	pass # Replace with function body.

func remove_all_games():
	for child in get_children():
		child.queue_free()

# Start a new game on the server
func start_game(players : Dictionary, game_mode:String, collisions:bool = false):
	# Only called by server
	if not is_network_master():
		return
	
	var hole_sequence = 'default'
	
	var game_id = UUID.NewID()
	srv_start_game(players, game_id, hole_sequence, game_mode, collisions)
	
	for id in players.keys():
		rpc_id(id, "srv_start_game", players, game_id, hole_sequence, game_mode, collisions)
	
	# Tell the server to start the first level
	get_node(game_id).start_next_level()
	
#	yield(get_tree().create_timer(1.0), "timeout")
#	get_node(game_id).spawn_players()
#	for id in players.keys():
#		get_node(game_id).rpc_id(id, "spawn_players")

func start_offline_game(player_data:Dictionary):
	var hole_sequence = 'default'
	
	var game_id = UUID.NewID()
	var players = {0:player_data}
	
	var game = OFFLINE_GAME_INSTANCE.instance()
	game.init(game_id, players, HOLE_SEQUENCES[hole_sequence])
	self.add_child(game)
	
	get_node(game_id).start_next_level()

puppetsync func srv_start_game(players : Dictionary, game_id:String,
level_sequence: String = "default", game_mode:String = "free-for-all",
collisions:bool = false):
	var game = GAME_INSTANCE.instance()
	game.init(game_id, players, HOLE_SEQUENCES[level_sequence], game_mode, collisions)
	self.add_child(game)
	if !is_network_master():
		visible = true
