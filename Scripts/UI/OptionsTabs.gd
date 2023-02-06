extends TabContainer

export (NodePath) var cursor_sound


func scroll_tab(dir, can_wrap = false):
	if  can_wrap:
		current_tab = wrapi(current_tab + dir, 0, get_tab_count())
	else:
		current_tab = clamp(current_tab + dir, 0, get_tab_count()-1)
	get_node(cursor_sound).play()
