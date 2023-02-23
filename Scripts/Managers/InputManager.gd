extends Control


enum control_scheme {
	KEYBOARD,
	MKB,
	GAMEPAD
}

var gameplay_controls = {
	"move_l" : "ui_keyboard_move_l",
	"move_r" : "ui_keyboard_move_r",
	"move_u" : "ui_keyboard_move_u",
	"move_d" : "ui_keyboard_move_d",
	"aim_l" : "ui_keyboard_move_l",
	"aim_r" : "ui_keyboard_move_r",
	"aim_u" : "ui_keyboard_move_u",
	"aim_d" : "ui_keyboard_move_d",
	"select" : "ui_keyboard_select",
	"cancel" : "ui_keyboard_cancel",
	"strafe" : "ui_keyboard_strafe",
	"special" : "ui_keyboard_special",
	"pause" : "ui_keyboard_pause",
}

var scheme_action_names = [
	"move_l","move_r","move_u","move_d",
	"aim_l","aim_r","aim_u","aim_d",
	"select",
	"cancel",
	"strafe",
	"special",
	"pause"
]

var scheme_actions = {
	control_scheme.KEYBOARD: {},
	control_scheme.MKB: {},
	control_scheme.GAMEPAD: {},
}
var action_to_scheme_map = {}


var current_control_scheme = control_scheme.KEYBOARD
var _cached_control_scheme = control_scheme.KEYBOARD

var _cached_focus_node


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

	# Populate the dicts used for detecting and processing the inputs for each control scheme
	for  action_name in scheme_action_names:

		var keyboard_action = "ui_keyboard_"+action_name
		var mkb_action = "ui_mkb_"+action_name
		var gamepad_action = "ui_gamepad_"+action_name

		scheme_actions[control_scheme.KEYBOARD][action_name] = keyboard_action
		scheme_actions[control_scheme.MKB][action_name] = mkb_action
		scheme_actions[control_scheme.GAMEPAD][action_name] = gamepad_action

		action_to_scheme_map[keyboard_action] = control_scheme.KEYBOARD
		action_to_scheme_map[mkb_action] = control_scheme.MKB
		action_to_scheme_map[gamepad_action] = control_scheme.GAMEPAD

	# Keyboard automatically aims in movement direction, and mkb doesn't use aim actions.  As precautions, erase them from the a2s map, set the former accordingly and the latter to inputs that can't be processed in that scheme (gamepad equivalents)
	for  dir in ["l","r","u","d"]:
		action_to_scheme_map.erase("ui_keyboard_aim_"+dir)
		action_to_scheme_map.erase("ui_mkb_aim_"+dir)

		scheme_actions[control_scheme.KEYBOARD]["aim_"+dir] = scheme_actions[control_scheme.KEYBOARD]["move_"+dir]
		scheme_actions[control_scheme.MKB]["aim_"+dir] = scheme_actions[control_scheme.GAMEPAD]["aim_"+dir]


func capture_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func release_mouse():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE



func update_control_scheme(event : InputEvent):

	# Switch control schemes based on input
	for  action in action_to_scheme_map:
		if  InputMap.event_is_action(event, action):
			current_control_scheme = action_to_scheme_map[action]
			#print ("CONTROL SCHEME SET TO ", current_control_scheme)

func update_gameplay_controls():
	# Update inputs table if switching control schemes
	if  _cached_control_scheme != current_control_scheme:
		_cached_control_scheme = current_control_scheme

		print ("GAMEPLAY CONTROLS UPDATED TO ", current_control_scheme, "\n")

		gameplay_controls = scheme_actions[current_control_scheme]
		
		#if  current_control_scheme != control_scheme.MKB:
		#	capture_mouse()



func _unhandled_input(event : InputEvent) -> void:
	update_control_scheme(event)
	update_gameplay_controls()


func _input(event : InputEvent) -> void:
	update_control_scheme(event)

	# Handle mouse capture and release, also directly switch to mkb on clicks
	if (event is InputEventMouseMotion):
		if  Input.mouse_mode == Input.MOUSE_MODE_HIDDEN  and  event.relative.length() > 0.5:
			release_mouse()

	elif  (event is InputEventMouseButton):
		release_mouse()
		current_control_scheme = control_scheme.MKB
	
	elif  (event is InputEventJoypadButton):
		capture_mouse()
		current_control_scheme = control_scheme.GAMEPAD

	elif  (TimeManager.is_paused  or  current_control_scheme != control_scheme.MKB):
		capture_mouse()

	# Refresh the gameplay controls accordingly
	update_gameplay_controls()




func _process(_delta):
	if _cached_focus_node != get_focus_owner():
		_cached_focus_node = get_focus_owner()
		#print ("\nFOCUS CHANGED: ", _cached_focus_node, "\n")
