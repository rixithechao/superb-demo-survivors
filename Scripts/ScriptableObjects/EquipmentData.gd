tool
extends Resource
class_name EquipmentData

enum EquipmentType {
	PASSIVE,
	WEAPON,
	PICKUP
}


export var name : String
export var icon : Texture
export(String, MULTILINE) var description = ""
export(int, 2,20) var max_level = 8
export var rarity : float = 100

export(Resource) var stats setget set_custom_stats,get_custom_stats
var _stats : Resource

export(Array, Resource) var level_modifiers setget set_custom_level_modifiers
var _level_modifiers

var equipment_type = EquipmentType.PASSIVE setget ,get_equipment_type

func get_equipment_type():
	return EquipmentType.PASSIVE



func set_max_level(val):
	max_level = val
	#level_modifiers.clear()

func get_max_level():
	return max_level



func set_custom_stats(val):
	_stats = val

func get_custom_stats():
	if  _stats == null  and  Engine.editor_hint:
		_stats = StatSheetData.new()

	return _stats




func set_custom_level_modifiers(value):
	if  true:#Engine.editor_hint:
		level_modifiers = value
		level_modifiers.resize(max(0, max_level-1))
		for i in level_modifiers.size():
			if not level_modifiers[i]:
				level_modifiers[i] = LevelModifierData.new()

			level_modifiers[i].resource_name = "Level " + String(i+2)
		
		_level_modifiers = level_modifiers



func apply_stats(modified, current_level = null):
	
	if current_level == null:
		if PlayerManager.equipment_levels.has(self):
			current_level = PlayerManager.equipment_levels[self]
		else:
			current_level = 1


	# Apply base stat modifications
	#print("APPLYING STATS FOR EQUIPMENT ", name, "\n", _stats.values, "\n")
	if _stats != null:
		_stats.apply_stats(modified)
	else:
		#print("EQUIPMENT ", name, " HAS NO BASE STATS!\n", _stats, "\n")
		pass


	# Go through each level up modifier
	if  current_level > 1:
		for i in range(current_level-1):
			#print (name, " CHECKING MODIFIER ", i)

			if _level_modifiers.size() > i:
				#print(name, " HAS LV. ", i, " MODIFIER")
				var modifier = _level_modifiers[i]
				modifier.apply_stats(modified)
	
	return modified



func _ready():
	pass



func b_set(prop_name: String, val) -> bool:
	# Assume the property exists
	var retval: bool = true
	
	# hardcoded properties
	match prop_name:
		
		"Max Level":
			max_level = val
			set_custom_level_modifiers(level_modifiers)
			property_list_changed_notify()

		"Level Modifiers":
			set_custom_level_modifiers(val)
			property_list_changed_notify()
	
	# return
	return retval

func b_get(prop_name: String):
	var retval = null

	# hardcoded properties
	match prop_name:
		"Stats/All ":
			return retval

	# return
	return retval

func b_get_property_list():
	var list = []
	

	list.append({
		"name": "Toggles/All",
		"type": TYPE_BOOL
	})
	
	list.append({
		"name": "Toggles/None",
		"type": TYPE_BOOL
	})
	
	list.append({
		"name": "Toggles/ ",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": ""
	})

	return list
