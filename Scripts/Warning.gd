extends Node2D
class_name Warning

export (bool) var spawning = false
export (float, 0.0, 120.0) var warning_seconds = 2.0
export (bool) var warning_sound = true
var time : float = 0
var percent : float = 0
var started_spawning : bool = false




func update_telegraphing():
	pass

func on_start_spawning():
	pass



func start():
	spawning = true
	if  warning_sound:
		$WarningSound.play()




func _ready():
	$Telegraph.modulate.a = 0
	pass

func _process(delta):
	if  not spawning  or  started_spawning:
		$Telegraph.modulate.a = 0
		return

	time += delta * TimeManager.time_rate
	if  warning_seconds > 0:
		percent = time/warning_seconds
	else:
		percent = 1

	$Telegraph/ProgressRotation/Progress.value = percent*100
	$Telegraph/ProgressRotation.global_rotation_degrees = 0
	$Telegraph.modulate.a = 1
	update_telegraphing()

	if  time >= warning_seconds  and  not started_spawning:
		started_spawning = true
		$Telegraph.modulate.a = 0
		on_start_spawning()
	pass

