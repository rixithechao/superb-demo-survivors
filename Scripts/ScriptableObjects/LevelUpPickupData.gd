tool
extends EquipmentData
class_name LevelUpPickupData

export var pickup : PackedScene
export var quantity : int


func get_equipment_type():
	return EquipmentType.PICKUP
