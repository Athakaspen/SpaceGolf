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

func _on_CreateLobby_pressed():
	NetworkManager.create_lobby
	pass # Replace with function body.

func on_new_lobby_data(lobbyData):
	# update from data
	for id in lobbyData:
		var panel = $LobbyList/VBoxContainer.get_node(id)
		if panel == null:
			# Create new panel
			panel = LOBBY_PANEL_SCENE.instance()
			panel.name = id
			$LobbyList/VBoxContainer.add_child(panel)
		# update data on panel
		panel.updateData(lobbyData[id])
	
	# remove panels not in latest data
	for panel in $LobbyList/VBoxContainer.get_children():
		if not panel.name in lobbyData.keys():
			panel.queue_free()


