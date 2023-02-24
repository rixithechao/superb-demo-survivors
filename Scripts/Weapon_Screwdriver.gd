extends "res://Scripts/Equipment_Spawner_LevelBasedPrefab.gd"


var _level


func _player_equipment_changed(eqp_type, type_array):
	._player_equipment_changed(eqp_type, type_array)
	
	if  _level != data.get_current_level():
		_level = data.get_current_level()
		
		if  _level == data.max_level:
			$SoundLoop.play()
