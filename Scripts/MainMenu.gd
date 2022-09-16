extends Control

var gradient_res = preload("res://Resources/TrailGradient.tres")

func _ready():
	randomize()
	GameService.hide()
	LobbyService.hide()
	get_tree().network_peer = null # force disconnect
	update_color()
	update_trail()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
#	_on_ChangeColor_pressed()
#	_on_ChangeTrail_pressed()

func _on_Offline_pressed():
# warning-ignore:return_value_discarded
#	get_tree().change_scene("res://Scenes/Level1.tscn")
	GameService.start_offline_game(NetworkManager.my_data)
	GameService.show()
	$"/root/MainMenu".queue_free()


func _on_Online_pressed():
	var name = $PlayerInfo/EnterName.text
	if name == "": name = "Anonymous"
	if name.length() > 20: name = name.substr(0,20)
	
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
	if rand_range(0,100) < 4:
		# hiic
		NetworkManager.my_data["sprite"] = 'hiic'
		NetworkManager.my_data["color"] = Color.white
	else:
		#normal
		NetworkManager.my_data["sprite"] = 'normal'
		NetworkManager.my_data["color"] = rand_color()
	update_color()

# update the graphic on the screen
func update_color():
	match NetworkManager.my_data["sprite"]:
		'hiic':
			$PlayerInfo/Sprite.texture = load("res://Sprites/hiicball.png")
		'normal':
			$PlayerInfo/Sprite.texture = load("res://Sprites/ball.png")
	$PlayerInfo/Sprite.modulate = NetworkManager.my_data["color"]

func _on_ChangeTrail_pressed():
	if rand_range(0,100) < 3:
		# rainbow
		NetworkManager.my_data["trail"] = 'rainbow'
	else:
		#normal
		NetworkManager.my_data["trail"] = 'normal'
		NetworkManager.my_data["trail_color"] = rand_color()
	update_trail()

# update the graphic on the screen
func update_trail():
	$PlayerInfo/Trail.gradient = get_gradient(NetworkManager.my_data['trail'], NetworkManager.my_data['trail_color'])

func rand_color() -> Color:
	return Color(rand_range(0,1),rand_range(0,1),rand_range(0,1))

func get_gradient(type:String, col:Color=Color.white) -> Gradient:
	match type:
		'rainbow':
			var grad = load("res://Resources/RainbowGradient.tres")
			return grad
		'normal', _:
			var grad = gradient_res.duplicate(true)
			for i in range(grad.get_point_count()):
				grad.set_color(i, Color(col.r, col.g, col.b, grad.get_color(i).a))
			return grad


func _on_Fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen
