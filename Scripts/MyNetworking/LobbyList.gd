extends Node2D

var LOBBY_PANEL_SCENE = preload("res://Scenes/MyNetworking/LobbyPanel.tscn")

func _ready():
	NetworkManager.connect("new_lobby_data", self, "on_new_lobby_data")


func _on_Refresh_pressed():
	NetworkManager.rq_lobby_data()


func _on_Back_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")


func _on_ConnectionCheckTimer_timeout():
	if(NetworkManager.isConnected):
		$Connecting.visible = false
		$Refresh.disabled = false
		$CreateLobby.disabled = false
		_on_Refresh_pressed()

func _on_CreateLobby_pressed():
	NetworkManager.rq_create_lobby($NewLobbyName.text)
	# remove scene
	self.queue_free()

func _on_JoinButton_pressed(lobby_id):
	NetworkManager.rq_join_lobby(lobby_id)
	# remove scene
	self.queue_free()


func on_new_lobby_data(lobbyData):
	if lobbyData.size() == 0:
		$NoLobbies.visible = true
	else:
		$NoLobbies.visible = false
	# update from data
	for id in lobbyData:
		var panel = $LobbyList/VBoxContainer.get_node_or_null(id)
		if panel == null:
			# Create new panel
			panel = LOBBY_PANEL_SCENE.instance()
			panel.name = id
			panel.connect("JoinButton_pressed", self, "_on_JoinButton_pressed")
			$LobbyList/VBoxContainer.add_child(panel)
		# update data on panel
		panel.updateData(lobbyData[id])
	
	# remove panels not in latest data
	for panel in $LobbyList/VBoxContainer.get_children():
		if not panel.name in lobbyData.keys():
			panel.queue_free()


