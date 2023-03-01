extends SaveableData
class_name Save_Records

export var ranks = { 0:"B-" }
export var longest_times = { 0:(24*60) + 37 }
export var highest_levels = {}
export var most_coins = {}
export var most_kills = {}
export var fewest_revives = {}

export var highest_level_ever = 1
export var most_coins_ever = 0



func get_save_path():
	return "user://save_records.res"
