tool
extends Sprite

export (float) var speed = 16.0

var time_elapsed

func _process(delta):
	if  time_elapsed == null:
		time_elapsed = 0
	
	time_elapsed = fmod(time_elapsed + speed*delta, 360)
	var percent = 0.5 + sin(deg2rad(time_elapsed)) * 0.5
	modulate.a = lerp(0.25, 0.75, percent)
	pass
