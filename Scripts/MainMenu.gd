extends Control



func _on_Offline_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Level1.tscn")


func _on_Online_pressed():
	var name = $EnterName.text
	if name == "": name = "Anonymous"
	
	# Get IP and port info
	var IP = $EnterIP.text
	var port = $EnterPort.text
	
	# Connect with default IP and port unless specified
	if IP == "" or port == "":
		NetworkManager.connect_to_server(name)
	else:
		NetworkManager.connect_to_server(name, IP, int(port))
	
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/MyNetworking/LobbyList.tscn")


func _on_Credits_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Credits.tscn")
