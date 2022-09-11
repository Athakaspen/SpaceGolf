extends Node

# How I ran as a server on GCP:  nohup ./Godot_v3.2.1-stable_linux_server.64 --main-pack SquaresClub.pck --network_connection_type=server &
const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 24601
const DEFAULT_MAX_PLAYERS = 64
const DEFAULT_CONNECTION_TYPE = "client"
const SERVER_ID = 1

var isConnected = false
signal new_lobby_data(lobby_data)

var players = {}
var my_data = {'name': null}

# Read args from cmd into dict
func parse_os_args():
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
	
	return arguments

func _ready():
	# Network signals.
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('network_peer_connected', self, '_on_player_connected')
	get_tree().connect('connected_to_server', self, '_on_connected_to_server')
	
	# Get arguments to check if this is the server.
	var args = parse_os_args()
	var network_connection_type = args.get('network_connection_type', DEFAULT_CONNECTION_TYPE)
	
	# Create the server if this code is ran the server.
	# And name the server "Server Host".
	if network_connection_type == 'server':
		print("Creating Server")
		create_server('Server Host')

# You're the server host and you create a server.
func create_server(server_host_name: String):
	my_data['name'] = server_host_name
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, DEFAULT_MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	players[SERVER_ID] = my_data

# Called when this client clicks "join",
# then the player connects to the server.
func connect_to_server(player_nickname: String, ip: String = DEFAULT_IP, port: int = DEFAULT_PORT):
	my_data['name'] = player_nickname
	
#	print("%s connected." % player_nickname)
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)
	
#	get_tree().get_root().get_node('World').create_player(player_nickname)

# Called when THIS client successfully connects to the server.
func _on_connected_to_server():
	Notifications.notify("Connection Successful")
	isConnected = true

# Client calls this to initiate a data transfer
func rq_lobby_data():
	rpc_id(SERVER_ID, "send_lobby_data")

# Runs on server, called by a client who wants a server list
master func send_lobby_data():
	print("Master send_lobby_data")
	var ServerScene = $"../ServerScene"
	if ServerScene != null and ServerScene.has_method("get_lobby_data"):
		# Actually sending data now
		var lobby_data = ServerScene.get_lobby_data()
		rpc_id(get_tree().get_rpc_sender_id(), "receive_lobby_data", lobby_data)
		print("Client RPC'd from server")
	else:
		print("ERROR: ServerScene not found")

# Runs on client, called by server (in send_lobby_data)
puppet func receive_lobby_data(lobby_data):
	print(lobby_data)
	emit_signal("new_lobby_data", lobby_data)

func rq_create_lobby(lobby_name:String):
	rpc_id(1, "create_lobby", lobby_name)

master func create_lobby(lobby_name:String):
	var newLobby = load("res://Scenes/MyNetworking/LobbyInstance.tscn").instance()
	

# Client calls this to pick a lobby to join
func join_lobby(lobby_id):
	pass

master func start_game():
	pass # it's time

# Notifies this client when ANOTHER player connects to the same server. 
# This also gets called for the server, but we don't do much with that. 
# 	In that case, other_player_id is 1 for the server.
func _on_player_connected(other_player_id):
	print("Player %s connected" % str(other_player_id))
	print("my id is %s" % str(get_tree().get_network_unique_id()))
#	var player_id = get_tree().get_network_unique_id()
	
	# This client asks the server for the new player's data.
#	if not(get_tree().is_network_server()):
#		rpc_id(1, 'get_player_data', player_id, other_player_id)

# Notified this client when ANOTHER player disconnects from the same server.
func _on_player_disconnected(other_player_id):
	print("Player %s disconnected" % str(other_player_id))
	print("my id is %s" % str(get_tree().get_network_unique_id()))
	if players.has(other_player_id):
		players.erase(other_player_id)
	# delete any player node in the world

# This function is called on the server.
# Tells the calling_player_id to create the new player (aka requsted_about_player_id).
#remote func get_player_data(calling_player_id, requested_about_player_id):
#	if get_tree().is_network_server():
#		rpc_id(calling_player_id, 'create_player', requested_about_player_id, players[requested_about_player_id])

# This function is called on this client.
# Create puppet player in this client's game.
#remote func create_player(other_player_id, data):
#	players[other_player_id] = data
#	var new_player = load("res://Scenes/NetworkDemo/Player.tscn").instance()
#	new_player.set_player_label(data["name"])
#	new_player.set_name(str(other_player_id))
#	new_player.set_network_master(other_player_id) # Tell this puppet player that it's being controlled by some other peer.
#	get_tree().get_root().get_node('World').add_child(new_player)
