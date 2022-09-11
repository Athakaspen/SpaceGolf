tool
extends Node2D

const XRES = 30
const YRES = 18

const LINESCALE := 6000.0

export(bool) var generate_points = false setget do_generate_points
export(bool) var update_points = false setget do_update_points

func do_generate_points(_p_generate_points = null):
	# Clear old points
	for child in get_children():
		child.queue_free()
	
	for i in range(XRES):
		for j in range(YRES):
			var l = Line2D.new()
			l.position = Vector2(i * (ProjectSettings.get("display/window/size/width") / XRES), 
				j * (ProjectSettings.get("display/window/size/height") / YRES))
			l.points = PoolVector2Array([Vector2.ZERO, Vector2.ZERO])
			add_child(l)
	
	do_update_points()

#func _process(delta):
#	do_update_points()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func do_update_points(_p_update_points = null):
	for child in get_children():
		if child is Line2D:
			var end = $"%PlanetsHolder".get_gravity_at_point(child.position) * LINESCALE
			if end.length_squared() < 30000:
				child.points[1] = end
			else:
				child.points[1] = Vector2.ZERO
