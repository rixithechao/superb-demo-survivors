extends "res://Scripts/UI/Menu.gd"

var button_hovered = false


func _ready():
	$Skew/Panel/CloseButton.connect("pressed", self, "begin_cancel_close")

	# If the screen resolution is too small, remove additional scale options
	var screen_size = OS.get_screen_size()
	var scale_tabs_node = $Skew/Panel/TabContainer/Display/ControlsGrid/HBoxContainer/WindowScaleTabs
	var scale_children = scale_tabs_node.get_children()
	
	for i in range(scale_children.size()-1, 0, -1):
		var child = scale_children[i]
		var this_size = Vector2(768, 432) * (i+1)
		
		if  this_size.x >= screen_size.x  or  this_size.y >= screen_size.y:
			child.queue_free()


	# Set the default states of the controls based on the saved settings
	$Skew/Panel/TabContainer/Audio/ControlsGrid/MusicVolumeSlider.value = SaveManager.settings.music_volume*100.0
	$Skew/Panel/TabContainer/Audio/ControlsGrid/SFXVolumeSlider.value = SaveManager.settings.sound_volume*100.0
	$Skew/Panel/TabContainer/Display/ControlsGrid/HBoxContainer/WindowScaleTabs.current_tab = (SaveManager.settings.screen_scale-1)
	$Skew/Panel/TabContainer/Display/ControlsGrid/FullscreenToggleCenter/FullscreenToggle.set_pressed_no_signal(SaveManager.settings.fullscreen)
	$Skew/Panel/TabContainer/Display/ControlsGrid/VsyncToggleCenter/VsyncToggle.set_pressed_no_signal(SaveManager.settings.vsync)
	$Skew/Panel/TabContainer/Effects/ControlsGrid/ScreenshakeToggleCenter/ScreenshakeToggle.set_pressed_no_signal(SaveManager.settings.screen_shake)
	$Skew/Panel/TabContainer/Effects/ControlsGrid/DamageNumToggleCenter/DamageNumToggle.set_pressed_no_signal(SaveManager.settings.damage_numbers)

func on_close():
	SaveManager.settings.save()


func _input_unhandled(event):
	var tab_nav = $Skew/Panel/TabNavigation
	if  not (event is InputEventMouse)  and  tab_nav.get_focus_owner() == null:
		$Skew/Panel/TabNavigation.grab_focus()



func _on_CloseButton_focus_entered():
	$CursorSound.play()
	pass # Replace with function body.


func _on_CloseButton_mouse_entered():
	$CursorSound.play()
	pass # Replace with function body.


# Controls changed

func _on_SaveDelayTimer_timeout():
	SaveManager.settings.save()



func _on_MusicVolumeSlider_value_changed(value):
	SaveManager.settings.music_volume = value*0.01
	AudioServer.set_bus_volume_db(SaveManager._bus_music, linear2db(SaveManager.settings.music_volume))
	$SaveDelayTimer.start()

func _on_SFXVolumeSlider_value_changed(value):
	SaveManager.settings.sound_volume = value*0.01
	AudioServer.set_bus_volume_db(SaveManager._bus_soundeffects, linear2db(SaveManager.settings.sound_volume))
	if  not $CursorSound.playing:
		$CursorSound.play()
	$SaveDelayTimer.start()

func _on_FullscreenToggle_toggled(button_pressed):
	SaveManager.settings.fullscreen = button_pressed
	OS.window_fullscreen = button_pressed
	$SaveDelayTimer.start()

func _on_VsyncToggle_toggled(button_pressed):
	SaveManager.settings.vsync = button_pressed
	OS.set_use_vsync(button_pressed)
	$SaveDelayTimer.start()

func _on_ScreenshakeToggle_toggled(button_pressed):
	SaveManager.settings.screen_shake = button_pressed
	$SaveDelayTimer.start()

func _on_DamageNumToggle_toggled(button_pressed):
	SaveManager.settings.damage_numbers = button_pressed
	$SaveDelayTimer.start()


func _on_WindowScaleTabs_tab_changed(tab):
	var sc = tab+1
	SaveManager.settings.screen_scale = sc
	#var old_screen_pos = OS.get_screen_position()
	OS.set_window_size(Vector2(768, 432) * sc)
	OS.center_window()
	#OS.set_screen_position(old_screen_pos)
	$SaveDelayTimer.start()

func _on_WindowScaleLeftArrow_pressed():
	var tabs = $Skew/Panel/TabContainer/Display/ControlsGrid/HBoxContainer/WindowScaleTabs
	tabs.scroll_tab(-1, true)
	$CursorSound.play()

func _on_WindowScaleRightArrow_pressed():
	var tabs = $Skew/Panel/TabContainer/Display/ControlsGrid/HBoxContainer/WindowScaleTabs
	tabs.scroll_tab(1, true)
	$CursorSound.play()
