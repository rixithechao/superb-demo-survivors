extends ItemList

export (NodePath) var menu_node
export (NodePath) var cursor_sound_node
export var active = true
export var immediate_focus = true

export var horizontal = false

export var custom_navigation = true

var item
var selected_cache = -1


const NAVIGATE_INPUTS_V = ["ui_up", "ui_down"]
const NAVIGATE_INPUTS_H = ["ui_left", "ui_right"]


signal item_hovered
signal item_chosen


func item_chosen():
	emit_signal("item_chosen", self, item)
	pass



func play_cursor_sound(should_force = null):
	var items_are_selected = (get_selected_items().size() > 0)

	if  should_force  or  (items_are_selected  and  selected_cache != get_selected_items()[0]):
		get_node(cursor_sound_node).play()

		if items_are_selected:
			selected_cache = get_selected_items()[0]


func hover_item(this_item):
	if  this_item >= get_item_count()  or  this_item < 0:
		return

	print(self.name, " changed the cursor to ", this_item)

	grab_focus()
	set_item_tooltip_enabled(this_item,false)
	item = this_item
	select(this_item, true)
	play_cursor_sound()
	emit_signal("item_hovered", this_item)
	pass




func _ready() -> void:
	var gotten_menu_node = get_node(menu_node)
	if  gotten_menu_node != null:
		self.connect("item_chosen", gotten_menu_node, "_on_item_chosen")
	
	if  immediate_focus:
		grab_focus()
		if  item == null:
			hover_item(0) 




func _on_ItemList_gui_input(event: InputEvent) -> void:
	if not active  or  Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return
	
	item = get_item_at_position(get_local_mouse_position(), true)
	if event is InputEventMouseMotion:
		if item != -1:
			hover_item(item)

	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		if item != -1:
			item_chosen()
		else:
			play_cursor_sound(true)


func _process(_delta):
	if  not active  or  not custom_navigation:
		return

	var navigate_inputs = NAVIGATE_INPUTS_V
	if  horizontal:
		navigate_inputs = NAVIGATE_INPUTS_H
	

	if (Input.is_action_just_pressed(navigate_inputs[0])):
		if item == null:
			item = 0
			grab_focus()
		
		var next_item = item
		var curr_item = item-1
		var valid_item_found = false
		while (curr_item >= 0  and  not valid_item_found):
			if  not is_item_disabled(curr_item):
				valid_item_found = true
				next_item = curr_item
			else:
				curr_item -= 1


		hover_item(next_item)


	elif Input.is_action_just_pressed(navigate_inputs[1]):
		if item == null:
			item = 0

		var next_item = item
		var curr_item = item+1
		var valid_item_found = false
		while (curr_item < get_item_count()  and  not valid_item_found):
			if  not is_item_disabled(curr_item):
				valid_item_found = true
				next_item = curr_item
			else:
				curr_item += 1

		hover_item(next_item)


	elif Input.is_action_just_pressed("ui_select") and item != null:
		item_chosen()
