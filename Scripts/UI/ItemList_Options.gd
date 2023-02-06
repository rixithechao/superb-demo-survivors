extends "res://Scripts/UI/ItemListTweaks.gd"


export (Array, NodePath) var controls_nodes = []


const SLIDER_MULT = 50


func handle_setting_widget(delta):
	
	var current_selection = get_selected_items()[0]
	if  current_selection == null:
		return
	
	var current_widget = get_node(controls_nodes[current_selection])
	match current_widget.get_class():

		"CheckBox":
			if  Input.is_action_just_pressed("ui_select"):
				play_cursor_sound(true)
				current_widget.pressed = not current_widget.pressed
				#regain_focus()

		"HSlider":
			if  Input.is_action_pressed("ui_left"):
				current_widget.value -= SLIDER_MULT * delta
				print("SLOIDIN, ", current_widget, ", delta=", delta, ", value=", current_widget.value)
				#regain_focus()

			if  Input.is_action_pressed("ui_right"):
				current_widget.value += SLIDER_MULT * delta
				print("SLOIDIN, ", current_widget, ", delta=", delta, ", value=", current_widget.value)
				#regain_focus()

		"TabContainer":
			if  Input.is_action_just_pressed("ui_left"):
				current_widget.scroll_tab(-1, true)
				#regain_focus()

			if  Input.is_action_just_pressed("ui_right"):
				current_widget.scroll_tab(1, true)
				#regain_focus()



func _ready():
	$"../../../../../RegainFocusTimer".connect("timeout", self, "_on_regain_focus_timer")
	._ready()


func _process(delta):
	active = get_parent().visible  and  get_focus_owner() == self
	._process(delta)
	
	if  not active:
		return

	var self_path = self.get_path()
	focus_neighbour_left = self_path
	focus_neighbour_right = self_path
	
	handle_setting_widget(delta)

	focus_neighbour_left = self_path
	focus_neighbour_right = self_path




func regain_focus():
	$"../../../../../RegainFocusTimer".start()

func _on_regain_focus_timer():
	grab_focus()
	#if  item == null:
	#	item = 0
	#hover_item(item)



func hover_item(index):
	.hover_item(index)
	var current_widget = get_node(controls_nodes[item])
	print ("Current widget = ", current_widget)



func _on_ItemList_item_selected(index):
	hover_item(index)
	pass # Replace with function body.


func _on_ItemList_focus_entered():
	play_cursor_sound(true)
	if item == null:
		hover_item(0)
	pass # Replace with function body.


func _on_ItemList_mouse_entered():
	grab_focus()
	pass # Replace with function body.

func _on_ItemList_mouse_exited():
	release_focus()
	pass # Replace with function body.
