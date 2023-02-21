extends Node2D
class_name Equipment

var data
var initialized = false

var _cached_stats = {}
var _is_dirty = true





func on_setup():
	pass

func on_process_equipment(_delta):
	pass




func get_stats():
	if _is_dirty:
		_cached_stats = data.apply_stats(PlayerManager.get_current_stats())
		_is_dirty = false
		print("EQUIPMENT ", name, " REFRESH STATS:\n", _cached_stats)

	return _cached_stats



func _player_equipment_changed(equipment_type, type_array):
	print("EQUIPMENT ", name, " IS NOW DIRTY")
	_is_dirty = true



func _ready():
	PlayerManager.connect("change_equipment", self, "_player_equipment_changed")


func _process(delta):
	if  not initialized:
		print("EQUIPMENT ", name, " NOT INITIALIZED")
		if  data != null:
			on_setup()
			initialized = true

	if  initialized  and  not (TimeManager.is_paused  or  PlayerManager.dead):
		on_process_equipment(delta)
