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
			
			if i==0:
				drops[i].resource_name = "Empty"
				drops[i].min_count = 0
				drops[i].max_count = 0
			else:
				drops[i].resource_name = "Drop"


func _ready():
	pass
