extends Resource
class_name DropTableEntry

export var pickup : Resource
export(int, 0,99) var min_count = 1
export(int, 0,99) var max_count = 1
export var weight : int = 1

func _ready():
	pass
