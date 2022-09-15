extends Control

var gradient_res = preload("res://Resources/TrailGradient.tres")

func _ready():
	randomize()
	GameService.hide()
	LobbyService.hide()

func _on_Offline_pressed():
# warning-ignore:return_value_discarded
#	get_tree().change_scene("res://Scenes/Level1.tscn")
	GameService.start_offline_game(NetworkManager.my_data)
	GameService.show()
	$"/root/MainMenu".queue_free()


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
	
	GameService.show()
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/MyNetworking/LobbyList.tscn")


func _on_Credits_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/Credits.tscn")


func _on_ChangeColor_pressed():
	if rand_range(0,100) < 30:
		#hiicball
		var ball = load("res://Sprites/hiicball.png")
		NetworkManager.my_data["sprite"] = ball
		NetworkManager.my_data["color"] = Color.white
	else:
		var ball = load("res://Sprites/ball.png")
		NetworkManager.my_data["sprite"] = ball
		NetworkManager.my_data["color"] = rand_color()
	$PlayerInfo/Sprite.texture = NetworkManager.my_data['sprite']
	$PlayerInfo/Sprite.modulate = NetworkManager.my_data["color"]

func _on_ChangeTrail_pressed():
	NetworkManager.my_data["trail"] = rand_trail()
	$PlayerInfo/Trail.gradient = NetworkManager.my_data["trail"]

func rand_color() -> Color:
	return Color(rand_range(0,1),rand_range(0,1),rand_range(0,1))

func rand_trail() -> Gradient:
	if rand_range(0,100) < 30:
		var grad = load("res://Resources/RainbowGradient.tres")
		return grad
	var col = Color(rand_range(0,1),rand_range(0,1),rand_range(0,1))
	var grad = gradient_res.duplicate(true)
	for i in range(grad.get_point_count()):
		grad.set_color(i, Color(col.r, col.g, col.b, grad.get_color(i).a))
	return grad
