tool
extends Resource
class_name OldStatSheetData

enum StatType {
	DAMAGE = 1 << 0,       # 1
	DEFENSE = 1 << 1,      # 2
	MAX_HP = 1 << 2,       # 4
	RECOVERY = 1 << 3,     # 8
	COOLDOWN = 1 << 4,     # 16
	AREA = 1 << 5,         # 32
	SPEED = 1 << 6,        # 64
	DURATION = 1 << 7,     # 128
	AMOUNT = 1 << 8,       # 256
	MOVEMENT = 1 << 9,     # 512
	PICKUP = 1 << 10,      # 1024
	LUCK = 1 << 11,        # 2048
	XP = 1 << 12,          # 4096
	MONEY = 1 << 13,       # 8192
}

const NUM_STATS = 14
const ALL_STATS_TOTAL = 16383

var flags = 0
var values = {}


func _ready():
	pass



func _set(prop_name: String, val) -> bool:
	# Assume the property exists
	var retval: bool = true
	
	# enum-based properties
	var enum_names = StatType.keys()
	
	for i in NUM_STATS:
		if flags & (1 << i) == 0:
			values[(1 << i)] = 0
		
		if prop_name == "Values/" + enum_names[i]:
			values[(1 << i)] = val
			print(values)
			property_list_changed_notify()
	
	# hardcoded properties
	match prop_name:
		
		"Toggles/All":
			flags = ALL_STATS_TOTAL
			property_list_changed_notify()

		"Toggles/None":
			flags = 0
			property_list_changed_notify()
		
		"Toggles/ ":
			flags = val
			property_list_changed_notify()
		
		_:
			# If here, trying to set a property we are not manually dealing with.
			retval = false
	
	# return
	return retval

func _get(prop_name: String):
	var retval = null

	# enum-based properties	
	var enum_names = StatType.keys()
	
	for i in NUM_STATS:
		if prop_name == "Values/" + enum_names[i]:
			if  values.has(1 << i):
				return values[(1 << i)]
			else:
				return 1

	# hardcoded properties
	match prop_name:
		"Toggles/ ":
			return flags

	# return
	return retval

func _get_property_list():
	var list = []

	var enum_names = StatType.keys()
	var enum_string = String(enum_names)
	var enum_sub = enum_string.substr(1, enum_string.length()-2).replace("_"," ")
	

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
		"hint_string": enum_sub
	})

	for i in NUM_STATS:
		if flags & (1 << i) != 0:
			list.append({
				"name": "Values/" + String(enum_names[i]),
				"type": TYPE_REAL,
				"hint": PROPERTY_USAGE_STORAGE
			})

	return list
