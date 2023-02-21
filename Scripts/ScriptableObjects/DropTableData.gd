tool
extends Resource
class_name DropTableData

export(Array, Resource) var drops setget set_custom_res

func set_custom_res(value):
	drops.resize(value.size())
	drops = value
	for i in drops.size():
		if not drops[i]:
			drops[i] = DropTableEntry.new()
			drops[i].resource_name = "Empty"

		else:
			var drip = drops[i]
			if  drip.pickup == null:
				drip.resource_name = "Empty"
			else:
				drip.resource_name = drip.pickup._bundled.names[0]


func get_drop():
	
	if  drops.size() == 0:
		return null
	
	# Derive a modifiable dictionary from the resources
	var modified_drops = {}
	for  drop in drops:
		var key = drop.pickup
		if  drop.pickup == null:
			key = "null"
		modified_drops[key] = drop.weight

	# Give equipment and such a chance to tamper with the dictionary
	PickupManager.emit_signal("modify_pickup_dropped", modified_drops)

	# Derive the weighted list
	var all_drops = []
	for key in modified_drops:
		for i in modified_drops[key]:
			all_drops.append(key)

	# Finally, the pickup is chosen and returned
	var chosen_drop = all_drops[randi() % all_drops.size()]
	if  chosen_drop is String:
		chosen_drop = null

	return chosen_drop





func _ready():
	pass
