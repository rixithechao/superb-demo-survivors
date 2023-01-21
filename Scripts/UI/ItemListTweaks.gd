extends ItemList

var active = true
var item
var selected_cache = -1


signal item_hovered


func item_chosen():
	print("BORP")
	pass



func play_cursor_sound(should_force = null):
	var items_are_selected = (get_selected_items().size() > 0)
	
	if  should_force  or  (items_are_selected  and  selected_cache != get_selected_items()[0]):
		$"../../../CursorSound".play()
		
		if items_are_selected:
			selected_cache = get_selected_items()[0]


func hover_item(item):
	select(item, true)
	play_cursor_sound()
	emit_signal("item_hovered", item)
	pass




func _ready() -> void:
	pass




func _on_ItemList_gui_input(event: InputEvent) -> void:
	if not active:
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
	if not active:
		return

	if Input.is_action_just_pressed("ui_up"):
		if item == null:
			item = 0
		
		item = max(0,item-1)
		hover_item(item)


	elif Input.is_action_just_pressed("ui_down"):
		if item == null:
			item = 0

		item = min(get_item_count()-1,item+1)
		hover_item(item)


	elif Input.is_action_just_pressed("ui_select") and item != null:
		item_chosen()
