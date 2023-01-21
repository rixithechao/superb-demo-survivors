extends Node

var anim_paused = false
var unpause_input_needed : String
var anim_player

var can_skip = false
var skip_time = 0.0


func on_close():
	pass
	

func close():
	on_close()
	MenuManager.close(self)

func next_menu(name: String):
	MenuManager.open(name)
	close()
	


func check_for_animation_player():
	anim_player = $AnimationPlayer
	return (anim_player != null)


func wait_for_input(input: String = "confirm"):
	if check_for_animation_player():
		anim_player.playback_active = false
		anim_paused = true
		unpause_input_needed = "ui_" + input

func set_skip(time: float):
	if check_for_animation_player():
		can_skip = true
		skip_time = time




func _process(_delta):

	if can_skip and Input.is_action_just_pressed("ui_cancel"):
		can_skip = false
		anim_player.advance(max(0, skip_time-anim_player.current_animation_position))

	if anim_paused and Input.is_action_just_pressed(unpause_input_needed):
		anim_paused = false
		anim_player.playback_active = true



