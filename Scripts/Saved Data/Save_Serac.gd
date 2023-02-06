extends SaveableData
class_name Save_Serac

export var meetings = 0
export var openings = 0
export var revives = 0
export var refusals_current = 0
export var refusals_total = 0



func get_save_path():
	return "user://save_serac.res"
