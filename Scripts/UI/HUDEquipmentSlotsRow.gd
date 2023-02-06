extends HBoxContainer


var slots_const : int
export(EquipmentData.EquipmentType) var slots_type
export var row_name_for_debug = ""

func _on_get_equipment(type, slots):
	if  type == slots_type:
		print("UPDATING EQUIPMENT IN HUD: ", row_name_for_debug, ", ", type, ", ", slots)
		resize(max(slots_const, slots.size()))
		set_graphics(slots)
		pass


func resize(new_size):
	var size = get_child_count()

	if size > new_size:
		for idx in range(size-1,new_size,-1):
			var child = get_child(idx)
			remove_child(child)
			child.queue_free()

	elif size < new_size:
		for _idx in range(size,new_size):
			var child = load("res://Prefabs/UI/Prefab_EquipmentSlot.tscn").instance()
			add_child(child)


func set_graphics(slots):
	for i in range(get_child_count()):
		var child = get_child(i)

		if i < slots.size():
			var eqp = slots[i]
			var lvl = PlayerManager.equipment_levels[eqp]
			child.update_gfx(eqp.icon, lvl)
		else:
			child.update_gfx(null, 0)


	
func _ready():
	PlayerManager.connect("change_equipment", self, "_on_get_equipment")
	set_graphics([])
