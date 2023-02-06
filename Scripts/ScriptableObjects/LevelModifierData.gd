tool
extends Resource
class_name LevelModifierData

enum LevelModifierType {StatSheet, Code, Both}

export(String, MULTILINE) var description = ""
var type = LevelModifierType.StatSheet
var stats : Resource
var modifier_script : Resource



func apply_stats(modified):
	#print ("APPLYING STAT MODIFIER FOR " + self.resource_name)

	# Process stats
	if  type != LevelModifierType.Code and stats != null:
		stats.apply_stats(modified)
	
	# Process code
	if  type != LevelModifierType.StatSheet and modifier_script != null:
		modifier_script.apply(modified)
		pass
		
	return modified





func get_stats_editor():
	if stats == null:
		stats = StatSheetData.new()
	stats.dont_debug = true

	return stats


func get_auto_description():
	var text = ""
	for stat in stats.stats:
		if  text != "":
			text += "; "
		
		text += stat.name + " "
		
		if stat.stack_type == 0:
			text += "+"
		else:
			text += "*"
		
		pass
	return text



func _ready():
	if  !Engine.editor_hint  and  (description == null or description == ""):
		description = get_auto_description()
		pass



func _set(prop_name: String, val) -> bool:
	# Assume the property exists
	var retval: bool = true
	
	# hardcoded properties
	match prop_name:
		
		"Stats":
			stats = val
			property_list_changed_notify()

		"Code":
			modifier_script = val
			property_list_changed_notify()

		"Type":
			type = val
			property_list_changed_notify()
		
		_:
			# If here, trying to set a property we are not manually dealing with.
			retval = false
	
	# return
	return retval

func _get(prop_name: String):
	var retval = null

	# hardcoded properties
	match prop_name:
		"Type":
			retval = type
		"Stats":
			retval = get_stats_editor()
		"Code":
			retval = modifier_script

	# return
	return retval

func _get_property_list():
	var list = []
	
	list.append({
		"name": "Type",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Stat Sheet, Code, Both"
	})

	if type != LevelModifierType.Code:
		list.append({
			"name": "Stats",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_USAGE_STORAGE
		})
	if type != LevelModifierType.StatSheet:
		list.append({
			"name": "Code",
			"type": TYPE_OBJECT,
			"hint": PROPERTY_USAGE_STORAGE
		})

	return list
