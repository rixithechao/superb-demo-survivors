extends Node


enum ResumeCondition {
	INPUT,
	SPEECH_PAGE,
	SPEECH_DONE,
	SPEECH_CLOSED,
	SELECTION
}


export var cancel_to_close : bool = false
export var cancel_sequence : String
export var cancel_menu : String

var can_cancel_close = true

var anim_paused = false
var unpause_conditions = {}
var anim_player

var can_skip = false
var skip_properties = {}
var skip_time = 0.0



signal menu_closed



# --- Virtual methods ---
func on_close():
	pass

func on_choose(_node, _item):
	pass



# --- Connections ---
func _on_bubble_done():
	if  anim_paused  and  unpause_conditions.type == ResumeCondition.SPEECH_DONE:
		resume()

func _on_bubble_closed():
	if  anim_paused  and  unpause_conditions.type == ResumeCondition.SPEECH_CLOSED:
		resume()

func _on_page_started(page_number):
	if  anim_paused  and  unpause_conditions.type == ResumeCondition.SPEECH_PAGE  and  page_number == unpause_conditions.page:
		resume()

func _on_item_chosen(node, item):
	on_choose(node, item)
	if  anim_paused  and  unpause_conditions.type == ResumeCondition.SELECTION  and  unpause_conditions.node == node:
		resume()



# --- Methods ---
func close():
	on_close()
	emit_signal("menu_closed", self)
	MenuManager.close(self)

func begin_cancel_close():
	$CloseSound.play()
	if check_for_animation_player():
		anim_player.play(cancel_sequence)

func cancel_close():
	if  cancel_menu != null  and  cancel_menu != "":
		next_menu(cancel_menu)
	else:
		close()

func next_menu(name: String):
	MenuManager.open(name)
	close()

func change_music(name: String):
	MusicManager.play_by_name(name)


func check_for_animation_player():
	anim_player = get_node_or_null("AnimationPlayer")
	return (anim_player != null)


func _wait_for_condition():
	if check_for_animation_player():
		anim_player.playback_active = false
		anim_paused = true
		unpause_conditions.clear()


func wait_for_input(input: String = "confirm"):
	_wait_for_condition()
	unpause_conditions = {"type": ResumeCondition.INPUT, "input": "ui_" + input}


func _wait_for_speech_bubble(bubble_path: NodePath, condition_type, signal_string):
	var bubble_node = get_node(bubble_path)
	if bubble_node != null:
		_wait_for_condition()
		unpause_conditions = {"type": condition_type, "node": bubble_node}
		bubble_node.connect(signal_string, self, "_on_"+signal_string)

func wait_for_speech_bubble_done(bubble_path: NodePath):
	_wait_for_speech_bubble(bubble_path, ResumeCondition.SPEECH_DONE, "bubble_done")
	pass

func wait_for_speech_bubble_closed(bubble_path: NodePath):
	_wait_for_speech_bubble(bubble_path, ResumeCondition.SPEECH_CLOSED, "bubble_closed")
	pass

func wait_for_speech_bubble_page(bubble_path: NodePath, page: int=1):
	_wait_for_speech_bubble(bubble_path, ResumeCondition.SPEECH_PAGE, "page_started")
	unpause_conditions.page = page
	pass


func wait_for_selection(list_path: NodePath):
	var list_node = get_node(list_path)
	if list_node != null:
		_wait_for_condition()
		unpause_conditions = {"type": ResumeCondition.SELECTION, "node": list_node}



func set_skip(time: float, sound: NodePath = ""):
	if check_for_animation_player():
		can_skip = true

		skip_properties.clear()
		skip_properties["time"] = time
		if  sound != "":
			skip_properties["sound"] = sound

func resume():
	anim_paused = false
	anim_player.playback_active = true



# --- Events ---
func _process(_delta):

	if  check_for_animation_player():

		if  Input.is_action_just_pressed("ui_select_or_cancel")  and  can_skip:
			can_skip = false
			anim_player.advance(max(0, skip_properties.time - anim_player.current_animation_position))
			if  skip_properties.has("sound"):
				var sound_node = get_node(skip_properties.sound)
				if  sound_node != null:
					sound_node.play()

		elif  Input.is_action_just_pressed("ui_cancel")  and  cancel_to_close  and  can_cancel_close:
			can_cancel_close = false
			begin_cancel_close()

	if  anim_paused:
		var should_resume = false
		
		match unpause_conditions.type:
			ResumeCondition.INPUT:
				if  Input.is_action_just_pressed(unpause_conditions.input):
					should_resume = true


		if  should_resume:
			resume()



