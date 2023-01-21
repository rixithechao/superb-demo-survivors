tool
extends EquipmentData
class_name PassiveData

func get_equipment_type():
	return EquipmentData.EquipmentType.PASSIVE


func apply_stats(modified, current_level = null):
	return .apply_stats(modified, current_level)
