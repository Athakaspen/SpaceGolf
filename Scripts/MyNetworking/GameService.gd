extends ViewportContainer

var GAME_INSTANCE = preload("res://Scenes/MyNetworking/GameInstance.tscn")

var HOLE_SEQUENCES = {
	"default":[
		"res://Scenes/Holes/Hole1.tscn",
		"res://Scenes/Holes/Hole2.tscn"
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
func start_game(players : Dictionary):
	# Only called by server
	if not is_network_master():
		return
	
	var game_id = UUID.NewID()
	srv_start_game(players, game_id)
	
	for id in players.keys():
		rpc_id(id, "srv_start_game", players, game_id)
	
	# Tell the server to start the first level
	get_node(game_id).start_next_level()
	
#	yield(get_tree().create_timer(1.0), "timeout")
#	get_node(game_id).spawn_players()
#	for id in players.keys():
#		get_node(game_id).rpc_id(id, "spawn_players")

puppetsync func srv_start_game(players : Dictionary, game_id:String, level_sequence: String = "default"):
	var game = GAME_INSTANCE.instance()
	game.init(game_id, players, HOLE_SEQUENCES[level_sequence])
	self.add_child(game)
	if !is_network_master():
		visible = true
