tool
extends Resource
class_name StatSheetData

export var stats : Array
export var values : Dictionary
var preset = 0
var dont_debug = true


func init_props():
	if stats == null:
		stats = []
		if !dont_debug:
			#print("INITIALIZING STATS ARRAY")
			pass
	if values == null:
		values = {}
		if !dont_debug:
			#print("INITIALIZING VALUES DICT")
			pass


func get(stat):
	init_props()
	return values[stat]


func apply_stats(modified):
	init_props()

	if !dont_debug:
		#print("LOOPING THROUGH ",stats)
		pass

	for stat in stats:
		if !dont_debug:
			#print("----\nAPPLYING ",stat.name)
			pass

		# If the property somehow hasn't been initialized, do that now
		if !modified.has(stat):
			if !dont_debug:
				#print("(ADDING TO PROVIDED TABLE)")
				pass

			modified[stat] = stat.base_value

		# Add
		if stat.stack_type == 0:
			modified[stat] += values[stat]
			if !dont_debug:
				#print(stat.name, " += ", values[stat])
				pass

		# Multiply
		else:
			modified[stat] *= values[stat]
			if !dont_debug:
				#print(stat.name, " *= ", values[stat])
				pass

	return modified



func set_to_defaults():
	# Initialize the stat array and/or values dict if need be
	init_props()
	
	for stat in stats:
		values[stat] = stat.base_value
	
	if !dont_debug:
		#print("STAT SHEET IN ", self.resource_path.get_file(), " SET TO DEFAULTS")
		pass



func _ready():
	pass


func _set(prop_name: String, val) -> bool:

	# Assume the property exists
	var retval: bool = true

	# Initialize the stat array and/or values dict if need be
	init_props()

	# If in the editor, allow changing the stats
	var stats_changed = false
	if Engine.editor_hint:

		# auto-generated properties
		for stat in stats:
			if  stat != null  and  prop_name == "Values/" + stat.name:
				values[stat] = val
				stats_changed = true
				property_list_changed_notify()
		
		# hardcoded properties
		match prop_name:
			
			"Stats":
				stats = val
				stats_changed = true
				property_list_changed_notify()
			
			"Values":
				values = val
				stats_changed = true
				property_list_changed_notify()
			
			"Preset or Remove":
				preset = 0

				match val:
					1: # Clear
						stats.clear()
						values.clear()
						stats_changed = true

					3: # Player
						stats.clear()
						values.clear()
						stats_changed = true
						stats.append_array([
								load("res://Data Objects/Stats/Stat_Damage.tres"),
								load("res://Data Objects/Stats/Stat_Defense.tres"),
								load("res://Data Objects/Stats/Stat_MaxHP.tres"),
								load("res://Data Objects/Stats/Stat_Recovery.tres"),
								load("res://Data Objects/Stats/Stat_Cooldown.tres"),
								load("res://Data Objects/Stats/Stat_Area.tres"),
								load("res://Data Objects/Stats/Stat_Speed.tres"),
								load("res://Data Objects/Stats/Stat_Duration.tres"),
								load("res://Data Objects/Stats/Stat_Amount.tres"),
								load("res://Data Objects/Stats/Stat_Movement.tres"),
								load("res://Data Objects/Stats/Stat_Pickup.tres"),
								load("res://Data Objects/Stats/Stat_Luck.tres"),
								load("res://Data Objects/Stats/Stat_XPMult.tres"),
								load("res://Data Objects/Stats/Stat_MoneyMult.tres")
							])
						set_to_defaults()

					4: # Enemy
						stats.clear()
						values.clear()
						stats_changed = true
						stats.append_array([
								load("res://Data Objects/Stats/Stat_MaxHP.tres"),
								load("res://Data Objects/Stats/Stat_Damage.tres"),
								load("res://Data Objects/Stats/Stat_Movement.tres"),
								load("res://Data Objects/Stats/Stat_Sturdiness.tres"),
								load("res://Data Objects/Stats/Stat_Inertia.tres"),
							])
						set_to_defaults()
						#values[StatsManager.MAX_HP] = 10

					5: # Weapon
						stats.clear()
						values.clear()
						stats_changed = true
						stats.append_array([
								load("res://Data Objects/Stats/Stat_Damage.tres"),
								#load("res://Data Objects/Stats/Stat_Area.tres"),
								#load("res://Data Objects/Stats/Stat_Speed.tres"),
								load("res://Data Objects/Stats/Stat_Amount.tres"),
								load("res://Data Objects/Stats/Stat_Duration.tres"),
								load("res://Data Objects/Stats/Stat_Pierce.tres"),
								load("res://Data Objects/Stats/Stat_Cooldown.tres"),
								load("res://Data Objects/Stats/Stat_ShotInterval.tres"),
								load("res://Data Objects/Stats/Stat_HitInterval.tres"),
								load("res://Data Objects/Stats/Stat_Knockback.tres"),
								load("res://Data Objects/Stats/Stat_EffectChance.tres"),
								load("res://Data Objects/Stats/Stat_Crit.tres")
							])
						set_to_defaults()

					_:
						if val >= 7:
							stats.remove(val-7)
							stats_changed = true


				# Refresh the property list
				property_list_changed_notify()
			
			_:
				# If here, trying to set a property we are not manually dealing with.
				retval = false
	
	# If not in the editor, basically cancel this event
	else:
		retval = false

	
	# Debug stats getting reset
	if !dont_debug:
		if stats_changed:
			#print("STATS CHANGED: ", values, "\n", prop_name, " = ", val, ", ", self.resource_path.get_file(), "\n\n")
			pass
		else:
			#print("STAT SHEET SET:\n", prop_name, " = ", val, ", ", self.resource_path.get_file(), "\n\n")
			pass

	# return
	return retval

func _get(prop_name: String):
	var retval = null

	# Initialize the stat array and/or values dict if need be
	init_props()

	# auto-generated properties
	for stat in stats:
		if  stat != null  and  prop_name == "Values/" + stat.name:
			if values.has(stat):
				retval = values[stat]
			else:
				if Engine.editor_hint:
					values[stat] = stat.base_value
					property_list_changed_notify()
					if !dont_debug:
						#print("STAT RESET:\n", stat.name, ", ", self.resource_path.get_file(), "\n\n")
						pass

					retval = values[stat]
				else:
					retval = null


	# hardcoded properties
	match prop_name:
		"Stats":
			retval = stats
		"Preset or Remove":
			retval = preset
		"Values":
			retval = values

	# return
	return retval

func _get_property_list():
	var list = []

	if  Engine.editor_hint:

		var remove_stat_options = ""

		for stat in stats:
			if stat != null:
				remove_stat_options += ",Remove " + stat.name
				var this_type = TYPE_INT
				if stat.type == 1:
					this_type = TYPE_REAL
				
				list.append({
					"name": "Values/" + stat.name,
					"type": this_type,
					"hint": PROPERTY_USAGE_STORAGE
				})

		list.append({
			"name": "Preset or Remove",
			"type": TYPE_INT,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": "None,Clear,--------,Player,Enemy,Weapon,--------" + remove_stat_options
		})

		#list.append({
		#	"name": "Stats",
		#	"type": TYPE_ARRAY,
		#	"hint": PROPERTY_USAGE_STORAGE
		#})

	return list
