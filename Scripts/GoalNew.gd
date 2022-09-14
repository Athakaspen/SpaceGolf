tool
extends Area2D

export(float, 0.004, 0.03, 0.001) var falloff = 0.01 setget set_falloff
export(float, 100, 2000, 100) var grav = 800.0 setget set_grav

func set_grav(new_grav):
	grav = new_grav
	if(self.is_inside_tree()):
		$GravityArea.gravity = new_grav

func set_falloff(new_fo):
	falloff = new_fo
	if(self.is_inside_tree()):
		$GravityArea.gravity_distance_scale = new_fo

func _ready():
	set_grav(grav)
	set_falloff(falloff)

var balls_inside = {}
const WIN_TIME = 1.0 # How long a ball has to be inside goal to win

func _on_Goal_body_entered(body):
	# Run in game only
	if Engine.editor_hint: return
	
	if body.is_in_group("Ball"):
		if body.name in balls_inside.keys():
			print("Something went wrong in goal logic")
		else:
			# Start timer for this ball
			var timer := Timer.new()
			add_child(timer)
			timer.wait_time = WIN_TIME
			timer.one_shot = true
			timer.start()
# warning-ignore:return_value_discarded
			timer.connect("timeout", self, "_on_wintimer_timeout", [body.name])
			balls_inside[body.name] = [body, timer]
			# Start win animation
			body.start_win_animation(WIN_TIME)

func _on_Goal_body_exited(body):
	if body.name in balls_inside.keys():
		# Ball left goal before winning
		balls_inside[body.name][1].queue_free() # remove timer
		balls_inside.erase(body.name) # remove entry in dict
		# Stop win animation
		body.reset_win_animation()

func _on_wintimer_timeout(ball_id:String):
	# Ball has been in goal long enough to win
	balls_inside[ball_id][0].on_win() # trigger win
	balls_inside[ball_id][1].queue_free() # remove timer
	balls_inside.erase(ball_id) # remove from dict
	
