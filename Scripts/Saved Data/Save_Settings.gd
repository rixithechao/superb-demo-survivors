extends SaveableData
class_name Save_Settings

export var music_volume = 0.7
export var sound_volume = 0.7

export var screen_scale = 1
export var fullscreen = false
export var vsync = false

export var screen_shake = true
export var damage_numbers = true

export var teeth = true


signal settings_changed


func _set(property: String, value) -> bool:
	emit_signal("settings_changed")
	return ._set(property, value)


func get_save_path():
	return "user://save_settings.res"
