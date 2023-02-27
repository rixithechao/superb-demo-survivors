tool
extends EquipmentData
class_name BoostData

export var stat_id = ""

func get_equipment_type():
	return EquipmentData.EquipmentType.BOOST


func apply_stats(modified, current_level = null):

	# Get the current level
	if current_level == null:
		if PlayerManager.equipment_levels.has(self):
			current_level = PlayerManager.equipment_levels[self]
		else:
			current_level = 1

	# Apply the same stat modifications once per level
	if _stats != null:
		for  i in range(current_level):
			_stats.apply_stats(modified)
	else:
		pass

	# Return the modified stat table
	return modified
