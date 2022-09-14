extends Node

# How I ran as a server on GCP:  nohup ./Godot_v3.2.1-stable_linux_server.64 --main-pack SquaresClub.pck --network_connection_type=server &
const DEFAULT_IP = '127.0.0.1'
#const DEFAULT_IP = '3.15.188.170'
const DEFAULT_PORT = 24601
const DEFAULT_MAX_PLAYERS = 64
const DEFAULT_CONNECTION_TYPE = "server"
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
# warning-ignore:return_value_discarded
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
# warning-ignore:return_value_discarded
	get_tree().connect('network_peer_connected', self, '_on_player_connected')
# warning-ignore:return_value_discarded
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
	isConnected = false
	peer.create_client(ip, port)
	get_tree().set_network_peer(peer)

# Called when THIS client successfully connects to the server.
func _on_connected_to_server():
	Notifications.notify("Connection Successful")
	rpc_id(1, "register_player", my_data)
	isConnected = true

master func register_player(data):
	players[get_tree().get_rpc_sender_id()] = data

# Client calls this to initiate a data transfer
func rq_lobby_data():
	rpc_id(SERVER_ID, "send_lobby_data")

# Runs on server, called by a client who wants a server list
master func send_lobby_data():
	var lobby_data = LobbyService.get_lobby_data()
	rpc_id(get_tree().get_rpc_sender_id(), "receive_lobby_data", lobby_data)

# Runs on client, called by server (in send_lobby_data)
puppet func receive_lobby_data(lobby_data):
#	print(lobby_data)
	emit_signal("new_lobby_data", lobby_data)

func rq_create_lobby(lobby_name:String):
	rpc_id(1, "create_lobby", lobby_name, get_tree().get_network_unique_id())

# Runs on server, creates the lobby
master func create_lobby(lobby_name:String, creator_id:int):
	var newLobby = load("res://Scenes/MyNetworking/LobbyInstance.tscn").instance()
	var lobby_id = UUID.NewID()
	newLobby.name = lobby_id
	newLobby.nickname = lobby_name
	newLobby.owner_id = creator_id
	LobbyService.add_child(newLobby)
	rpc_id(creator_id, "svr_create_lobby", lobby_id, lobby_name, creator_id)
	newLobby.on_player_joined(creator_id, players[creator_id])

# Called by server on clients to put them in a lobby
puppet func svr_create_lobby(lobby_id:String, lobby_name:String, creator_id:int):
	var newLobby = load("res://Scenes/MyNetworking/LobbyInstance.tscn").instance()
	newLobby.name = lobby_id
	newLobby.nickname = lobby_name
	newLobby.owner_id = creator_id
	LobbyService.add_child(newLobby)
	GameService.visible = false
	LobbyService.visible = true

# Client calls this to pick a lobby to join
func rq_join_lobby(lobby_id:String):
	rpc_id(1, "join_lobby", lobby_id)

master func join_lobby(lobby_id:String):
	var player_id = get_tree().get_rpc_sender_id()
	var lobby = LobbyService.get_node_or_null(lobby_id)
	if lobby == null: print("Attempt to join nonexistent lobby")
	rpc_id(player_id, "svr_create_lobby", lobby_id, lobby.nickname, lobby.owner_id)
	lobby.on_player_joined(player_id, players[player_id])

# Notifies this client when ANOTHER player connects to the same server. 
# This also gets called for the server, but we don't do much with that. 
# 	In that case, other_player_id is 1 for the server.
func _on_player_connected(other_player_id):
	print("Player %s connected" % str(other_player_id))
#	print("my id is %s" % str(get_tree().get_network_unique_id()))
#	var player_id = get_tree().get_network_unique_id()
	
	# This client asks the server for the new player's data.
#	if not(get_tree().is_network_server()):
#		rpc_id(1, 'get_player_data', player_id, other_player_id)

# Notified this client when ANOTHER player disconnects from the same server.
func _on_player_disconnected(other_player_id):
	print("Player %s disconnected" % str(other_player_id))
	if(is_network_master()):
		for lobby in LobbyService.get_children():
			if other_player_id in lobby.players.keys():
				lobby.on_player_left(other_player_id)
				break
		for game in GameService.get_children():
			if other_player_id in game.players.keys():
				game.on_player_left(other_player_id)
				break
		if players.has(other_player_id):
			players.erase(other_player_id)
	# server disconnect (i dont think this works)
	elif(1==other_player_id):
		Notifications.notify("Disconnect from server")
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Scenes/MainMenu.tscn")
		LobbyService.remove_all_lobbies()
	# delete any player node in the world
