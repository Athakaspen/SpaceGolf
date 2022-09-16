extends Control

onready var turnLabel = $TurnLabel
onready var scoreLabel = $ScoreLabel
onready var timerBar = $TimerBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_turn(player_name:String):
	turnLabel.text = player_name + "'s turn"
func hide_turns():
	turnLabel.hide()

func update_scores(players:Dictionary, player_scores:Dictionary):
	var scoretexts = []
	for id in player_scores.keys():
		scoretexts.append([player_scores[id], "%s: %s\n" % [players[id]["name"], stepify(player_scores[id], 0.01)]])
	scoretexts.sort_custom(MyCustomSorter, 'sort_ascending')
	var text = ""
	for entry in scoretexts:
		text += entry[1]
	scoreLabel.text = text

class MyCustomSorter:
	static func sort_ascending(a, b):
		if a[0] < b[0]:
			return true
		return false

func update_timer(amount:float):
	timerBar.value = amount

remotesync func hide_timer():
	timerBar.hide()
