extends Button



func _process(_delta):
	if  not has_focus():
		return
	
	var cont = $"../TabContainer"

	if  Input.is_action_just_pressed("ui_left"):
		cont.scroll_tab(-1)
	if  Input.is_action_just_pressed("ui_right"):
		cont.scroll_tab(1)

	var current_tab_child = cont.get_current_tab_control()
	var self_path = self.get_path()
	
	focus_neighbour_bottom = current_tab_child.get_node("ItemList").get_path()
	focus_neighbour_top = self_path
	focus_neighbour_left = self_path
	focus_neighbour_right = self_path


func _on_TabNavigation_focus_entered():
	grab_focus()
	$"../../../CursorSound".play()


func _on_TabContainer_tab_selected(_tab):
	grab_focus()
	$"../../../CursorSound".play()
