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

func _on_Goal_body_entered(body):
	
	# Run in game only
	if Engine.editor_hint: return
	
	if body.is_in_group("Ball"):
		print("YOU WIN")
