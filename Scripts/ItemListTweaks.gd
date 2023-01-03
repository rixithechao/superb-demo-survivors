extends ItemList

var item



func item_chosen():
	pass




func _ready() -> void:
	pass

func _on_ItemList_gui_input(event: InputEvent) -> void:
	item = get_item_at_position(get_local_mouse_position(), true)
	if event is InputEventMouseMotion:
		if item != -1:
			select(item, true)
	elif event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_LEFT:
		if item != -1:
			item_chosen()
			pass
	# here, item is selected (you can add or fix code here)

func _process(delta):

	if Input.is_action_just_pressed("ui_up"):
		if item != null:
			item = max(0,item-1)
			select(item, true)
		else:
			item = 0

	elif Input.is_action_just_pressed("ui_down"):
		if item != null:
			item = min(get_item_count()-1,item+1)
			select(item, true)
		else:
			item = get_item_count()-1

	elif Input.is_action_just_pressed("ui_accept") and item != null:
		item_chosen()
