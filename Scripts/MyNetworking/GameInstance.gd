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
	for id in players.keys():
		var ball = PLAYER_SCENE.instance()
		ball.name = str(id)
		ball.setName(players[id]["name"])
		ball.position = spawn_point
		ball.set_network_master(id)
		$PLAYERS.add_child(ball)

func create_player(name : String = "UNNAMED", color : Color = Color.white):
	var newPlayer = PLAYER_SCENE.instance()
	newPlayer.setName(name)
	newPlayer.setColor(color)
	$PLAYERS.add_child(newPlayer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
