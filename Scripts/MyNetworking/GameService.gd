extends ViewportContainer

var GAME_INSTANCE = preload("res://Scenes/MyNetworking/GameInstance.tscn")

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
	var game = srv_start_game(players, game_id, "res://Scenes/Hole1.tscn")
	
	for id in players.keys():
		rpc_id(id, "srv_start_game", players, game_id, "res://Scenes/Hole1.tscn")
	
	yield(get_tree().create_timer(1.0), "timeout")
	game.spawn_players()
	for id in players.keys():
		game.rpc_id(id, "spawn_players")

puppetsync func srv_start_game(players : Dictionary, game_id:String, level: String):
	var game = GAME_INSTANCE.instance()
	game.name = game_id
	game.players = players
	game.load_level(level)
	self.add_child(game)
	if !is_network_master():
		visible = true
	else:
		return game
