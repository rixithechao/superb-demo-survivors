extends Control

var progress : float = 0


func _process(_delta):
	$ProgressBar.value = progress
	
	#if UIManager.hud != null and get_parent() != UIManager.hud:
	#	get_parent().remove_child(self)
	#	UIManager.hud.add_child(self)


func wait_for_loading():
	UIManager.emit_signal("load_screen_faded_in")

func finish():
	print("FINISHED LOADING")
	$AnimationPlayer.play("Sequence_Exit")
