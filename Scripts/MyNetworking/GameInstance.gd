extends Viewport


var PORT = 0
var MAX_PLAYERS = 8
var SERVER_ID = 1

var PLAYER_SCENE = preload("res://LevelObjects/Ball.tscn")

var players = {}
var players_loaded = []
var players_finished = []
var turn_order = []
var cur_turn = -1
var player_scores = {}
var player_times = {}
var level_sequence = {}
var cur_level
var game_mode : String
var collisions_enabled := false
var started := false # whether the round timing has started

onready var camera = $Camera
onready var UI = $UILayer/UI

var spawn_point = Vector2.ZERO

# Send an RPC to every player in this game. Called by player object.
func rpc_local(calling_player:Node, func_name:String, args:Array = []):
	for id in [1] + players.keys():
		if id != get_tree().get_network_unique_id():
			var arglist = [id, func_name] + args
			calling_player.callv("rpc_id", arglist)

# Send an Unreliable RPC to every player in this game. Called by player object.
func rpc_local_unreliable(calling_player:Node, func_name:String, args:Array = []):
	for id in [1] + players.keys():
		if id != get_tree().get_network_unique_id():
			var arglist = [id, func_name] + args
			calling_player.callv("rpc_unreliable_id", arglist)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Time scoring
func _process(delta):
		if game_mode == 'free-for-all':
			if is_network_master():
				if started:
					for id in players.keys():
						if not id in players_finished:
							player_times[id] += delta
#				UI.update_scores(players, player_times)
				rpc_local(self, "update_times", [player_times])
			else:
				UI.update_scores(players, player_times)
		else:
			UI.update_scores(players, player_scores)

puppet func update_times(new_times):
	player_times = new_times

func init(game_id:String, player_list:Dictionary, level_series:Array, mode:String, collisions:bool):
	name = game_id
	players = player_list
	level_sequence = level_series
	cur_level = -1
	game_mode = mode
	collisions_enabled = collisions
	# init scores to 0
	for id in players.keys():
		player_scores[id] = 0.0
		player_times[id] = 0.0
	
	# this only matters on the server
	turn_order = players.keys()
#	turn_order.shuffle()

func start_next_level():
	# Server Only
	if !is_network_master(): return
	
	if cur_level < level_sequence.size() - 1:
		if game_mode == "free-for-all":
			UI.hide_timer()
			rpc_local(UI, "hide_timer")
		goto_next_level()
		rpc_local(self, "goto_next_level")
		players_loaded = []
	else:
		print("GAME OVER, deleting")
		rpc_local(self, "goto_winscreen")
		self.queue_free()

puppet func goto_winscreen():
	clear_level()
	NetworkManager.result_players = players
	NetworkManager.result_scores = player_scores
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/WinScreen.tscn")
	self.queue_free()

puppetsync func goto_next_level():
	clear_level()
	yield(get_tree(), "idle_frame") # wait until level is really gone
	yield(get_tree(), "idle_frame") # wait until level is really gone
	cur_level += 1
#	UI.update_scores(players, player_scores)
	if game_mode == 'free-for-all':
		UI.hide_turns()
	load_level(level_sequence[cur_level])

# Called by client when their turn is done
mastersync func turn_finished():
	var next_id = get_next_turn()
	rpc_local(self, "update_turn", [next_id])

puppet func update_turn(id):
	UI.update_turn(players[id]["name"])
	if id == get_tree().get_network_unique_id():
		$PLAYERS.get_node(str(id)).start_turn()

# Updates internal variables and returns next player ID
func get_next_turn() -> int:
	if turn_order.size() <= players_finished.size():
		# This shouldn't happen, but if it does, I don't want to stack overflow
		return turn_order[0]
	cur_turn += 1
	# loop
	if cur_turn >= turn_order.size():
		cur_turn -= turn_order.size()
	if not turn_order[cur_turn] in players_finished:
		return turn_order[cur_turn]
	else:
		#recursion? in a real project?
		return get_next_turn()

func load_level(level_path:String):
	var level = load(level_path).instance()
	add_child(level)
	level.get_node("SpawnPoint").visible = false
	camera.position = level.get_node("CameraPos").position
	spawn_point = level.get_node("SpawnPoint").position
#	Notifications.notify("Level Loaded")
	
	# Tell server we've loaded
	if !is_network_master():
		rpc_id(1, "done_preconfiguring")

# Straight from the docs
master func done_preconfiguring():
	var who = get_tree().get_rpc_sender_id()
	# Here are some checks you can do, for example
	assert(get_tree().is_network_server())
	assert(who in players.keys()) # Exists
	assert(not who in players_loaded) # Was not added yet

	players_loaded.append(who)

	if players_loaded.size() == players.size():
		yield(get_tree().create_timer(0.5), "timeout") # dramatic start
		spawn_players()
		rpc_local(self, "spawn_players")
		if game_mode == "turns":
			yield(get_tree().create_timer(0.5), "timeout") # time to load
			rpc_local(self, "update_turn", [get_next_turn()])

# Remove all existing level data from the game instance
func clear_level():
	players_finished = []
	started = false
	for child in get_children():
		if child.name == "PLAYERS":
			# clear players but keep parent node
			for chchild in child.get_children():
				chchild.queue_free()
		elif child.name == "LEVEL":
			child.queue_free()
		else:
			# ignore anythine else
			pass

puppetsync func spawn_players():
	var grav_bit = 8
	for id in players.keys():
		var ball = PLAYER_SCENE.instance()
		ball.init(id, spawn_point, grav_bit, game_mode)
		ball.setName(players[id]["name"])
		ball.setColor(players[id]["color"])
		match players[id]["sprite"]:
			'normal':
				ball.setSprite(load("res://Sprites/ball.png"))
			'hiic':
				ball.setSprite(load("res://Sprites/hiicball.png"))
		ball.setTrail(get_gradient(players[id]["trail"], players[id]["trail_color"]))
		ball.setCollisions(collisions_enabled)
		grav_bit += 1
		ball.set_network_master(id)
		$PLAYERS.add_child(ball)
		if id == get_tree().get_network_unique_id():
			camera.focus = ball
	started = true

func get_gradient(type:String, col:Color=Color.white) -> Gradient:
	match type:
		'rainbow':
			var grad = load("res://Resources/RainbowGradient.tres")
			return grad
		'normal', _:
			var grad = load("res://Resources/TrailGradient.tres").duplicate(true)
			for i in range(grad.get_point_count()):
				grad.set_color(i, Color(col.r, col.g, col.b, grad.get_color(i).a))
			return grad

func create_player(name : String = "UNNAMED", color : Color = Color.white):
	var newPlayer = PLAYER_SCENE.instance()
	newPlayer.setName(name)
	newPlayer.setColor(color)
	$PLAYERS.add_child(newPlayer)

func on_player_left(other_player_id):
	# Only called by server
	if is_network_master():
		var i = turn_order.find(other_player_id)
		if cur_turn > i:
			cur_turn -= 1
		elif cur_turn == i:
			turn_finished()
		erase_player(other_player_id)
		if players.size() == 0:
			print("Game Empty, deleting")
			self.queue_free()
			return
		for id in players.keys():
			rpc_id(id, "erase_player", other_player_id)

remotesync func erase_player(other_player_id):
	if players.has(other_player_id):
		print("PLAYER %s DISCONNECTED IN-GAME" % other_player_id)
		Notifications.notify("%s (%s) has disconnected." % [players[other_player_id]["name"], other_player_id])
# warning-ignore:return_value_discarded
		players.erase(other_player_id)
		player_scores.erase(other_player_id)
		player_times.erase(other_player_id)
		players_finished.erase(other_player_id)
		turn_order.erase(other_player_id)
#		UI.update_scores(players, player_scores)
	var ball = $PLAYERS.get_node_or_null(str(other_player_id))
	if ball != null:
		ball.queue_free()

remotesync func log_hit(id):
	player_scores[id] += 1
#	UI.update_scores(players, player_scores)

remotesync func update_timer(amount):
	UI.update_timer(amount)

func on_win():
	rpc_id(1, "register_completion")
	camera.focus = null

master func register_completion():
	var player_id = get_tree().get_rpc_sender_id()
	if player_id in players_finished: return
	players_finished.append(player_id)
	rpc_local(self, "update_completion", [players_finished])
	
	if players_finished.size() == players.size():
		start_next_level()

puppet func update_completion(new_data):
	players_finished = new_data
