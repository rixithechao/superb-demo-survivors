extends SaveableData
class_name Save_Progress

export var shop_upgrades = {}
export var normal_stage_clears = {}
export var special_stage_unlocks = {}
export var character_unlocks = {}
export var equipment_unlocks = {}


func get_save_path():
	return "user://save_progress.res"
