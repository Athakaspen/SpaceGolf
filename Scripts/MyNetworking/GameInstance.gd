extends Viewport


var PORT = 0
var MAX_PLAYERS = 8
var SERVER_ID = 1

var PLAYER_SCENE = preload("res://LevelObjects/Ball.tscn")

var players = {}
var my_data = {'name': null, 'transform': null}

var spawn_point = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func load_level(level_path:String):
	var level = load(level_path).instance()
	add_child(level)
	spawn_point = level.get_node("SpawnPoint").position
	Notifications.notify("Level Loaded")

puppetsync func spawn_players():
	var grav_bit = 8
	for id in players.keys():
		var ball = PLAYER_SCENE.instance()
		ball.name = str(id)
		ball.setName(players[id]["name"])
		ball.position = spawn_point
		ball.MY_GRAVITY_BIT = grav_bit
		grav_bit += 1
		ball.set_network_master(id)
		$PLAYERS.add_child(ball)

func create_player(name : String = "UNNAMED", color : Color = Color.white):
	var newPlayer = PLAYER_SCENE.instance()
	newPlayer.setName(name)
	newPlayer.setColor(color)
	$PLAYERS.add_child(newPlayer)

func on_player_left(other_player_id):
	# Only called by server
	if is_network_master():
		erase_player(other_player_id)
		if players.size() == 0:
			print("Game Empty, deleting")
			self.queue_free()
			return
		for id in players.keys():
			rpc_id(id, "erase_player", other_player_id)

remotesync func erase_player(other_player_id):
	if players.has(other_player_id):
		print("PLAYER DISCONNECTED")
		Notifications.notify("%s (%s) has disconnected." % [players[other_player_id]["name"], other_player_id])
# warning-ignore:return_value_discarded
		players.erase(other_player_id)
	var ball = $PLAYERS.get_node_or_null(str(other_player_id))
	if ball != null:
		ball.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
