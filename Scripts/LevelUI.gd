extends Control

onready var turnLabel = $TurnLabel
onready var scoreLabel = $ScoreLabel
onready var timerBar = $TimerBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_turn(player_name:String):
	turnLabel.text = player_name + "'s turn"

func update_scores(players:Dictionary, player_scores:Dictionary):
	var text = ""
	for id in player_scores.keys():
		text += "%s: %s\n" % [players[id]["name"], player_scores[id]]
	scoreLabel.text = text

func update_timer(amount:float):
	timerBar.value = amount

remotesync func hide_timer():
	timerBar.hide()
