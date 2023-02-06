extends Warning


export (Vector2) var viewport_snap = Vector2(0,0)


func update_telegraphing():
	var vp = CameraManager.instance.get_viewport()
	position = vp.size*viewport_snap
	
	var radius = $Telegraph/Direction/Length/TextureRect.rect_size.y / 2
	var new_radius = lerp(radius, 1, fmod(4*percent, 1.0))

	# Time indicators
	$Telegraph/Direction/Length/TimeLeftLine.position.y = -new_radius
	$Telegraph/Direction/Length/TimeRightLine.position.y = new_radius
	pass

func on_start_spawning():
	self.queue_free()
