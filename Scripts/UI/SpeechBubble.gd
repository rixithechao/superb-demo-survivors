tool
extends Control


const CUSTOM_TEXT_EFFECTS = [
	preload("res://Scripts/Rich Text Effects/RichTextMatrix.gd")
]

export var autoplay = false
export var active = false
export var interactive = true

export (String) var text_name setget set_text_name 
export (Array, String, MULTILINE) var text_body setget set_text_body
export (int) var current_page setget set_current_page
export (float, 0,1) var tail_position setget set_tail_position
export (int, "Left", "Right") var tail_direction setget set_tail_direction

export (float, 0, 128) var text_speed = 1.0



var typing_timer : float = 0
var shown_chars : int = 0

var _is_text_dirty = true
var _is_shownchars_dirty = true


onready var body_label = self.get_node("Text/Body")




const FADE_LENGTH = 0#4


signal page_started
signal page_done
signal bubble_done
signal bubble_closed


func is_last_page():
	return (current_page == text_body.size()-1)



func start_page(num, is_complete : bool = false):
	current_page = clamp(num, 0, text_body.size()-1)
	_is_text_dirty = true
	
	if is_complete:
		shown_chars = -1
	else:
		shown_chars = 0
	
	emit_signal("page_started", num)

func finish_page():
	shown_chars = -1
	_is_text_dirty = true
	_is_shownchars_dirty = true

	emit_signal("page_done", current_page)
	if  is_last_page():
		emit_signal("bubble_done")



func next_page():
	if  not is_last_page():
		print("NOT LAST PAGE. last=", text_body.size()-1, ", current=", current_page)
		start_page(current_page + 1, false)

	else:
		close()




func start():
	start_page(0, false)
	modulate.a = 1
	active = true
	pass

func close():
	if  not Engine.editor_hint:
		interactive = false
		active = false
		emit_signal("bubble_closed")
		$AnimationPlayer.play("Sequence_CloseSpeechBubble")




func set_text_name(value):
	if  value == null:
		value = ""

	text_name = value
	_is_text_dirty = true

func set_text_body(value):
	text_body.resize(value.size())
	text_body = value
	_is_text_dirty = true

	if  not Engine.editor_hint:
		return

	start_page(current_page)


func set_current_page(value):
	if  active:
		start_page(value)


func set_tail_position(value):
	tail_position = value
	var tail_range = $Box/Tail
	var new_position = Vector2(lerp(0, tail_range.rect_size.x, value), 0)
	$Box/Tail/TailCenter.rect_position = new_position

func set_tail_direction(value):
	tail_direction = value
	$Box/Tail/TailCenter.rect_scale.x = (-1 if value == 1 else 1)







func refresh_visuals():
	$Text/Name.bbcode_text = text_name

	var page_text = text_body[current_page]
	$Text/Body.bbcode_text = page_text
	$Text.collapsed = (text_name == null  or  text_name == "")
	
	#if  shown_chars == -1:
	#	body_label.bbcode_text = page_text
	#else:
	#	var tag_start = "[fade start=%s length=%s]" % [shown_chars-FADE_LENGTH, FADE_LENGTH]
	#	body_label.bbcode_text = tag_start + page_text + "[/fade]"
	pass




func _enter_tree():
	if not InputMap.has_action("ui_select_or_cancel"):
		InputMap.add_action("ui_select_or_cancel")

func _ready():
	if  not Engine.editor_hint:
		if  autoplay:
			start()
		else:
			modulate.a = 0

	#for fx in CUSTOM_TEXT_EFFECTS:
	#	body_label.install_effect(fx)
	#	body_label.install_effect(fx)


func _process(delta):

	# Refresh the visuals
	if  _is_text_dirty:
		refresh_visuals()
		_is_text_dirty = false

	$Text/Body.visible_characters = shown_chars


	if  not active:
		return


	# Typewriter effect
	var is_complete = shown_chars == -1
	$Box/ContinueIcon.modulate.a = (1 if (is_complete and interactive) else 0)
	$Box/ContinueIcon/Sprite.frame = (1 if is_last_page() else 0)

	if  not is_complete:

		# Reveal text
		var new_chars_revealed = false
		
		typing_timer += delta * 20 * text_speed
		while (typing_timer >= 1):
			typing_timer -= 1
			shown_chars += 1
			new_chars_revealed = true

		# Update fade effect
		if  new_chars_revealed:
			$RandomAudioNodePlayer.play()
			#_is_text_dirty = true
			pass

		# Check if page is done
		if  (shown_chars >= $Text/Body.text.length() + FADE_LENGTH)  or  (interactive  and  Input.is_action_just_pressed("ui_select_or_cancel")):
			 finish_page()


	# Allow skipping to the end
	elif  interactive  and  Input.is_action_just_pressed("ui_select_or_cancel"):
		next_page()



