extends Resource
class_name StatData

enum StatStackType {ADD, MULT}
enum StatCategory {CHARACTER, PROJECTILE, GLOBAL}

export(String) var name
#export(StatCategory) var category
export(int, "int", "float") var type
export(StatStackType) var stack_type
export(float) var base_value = 1.0
export(String, MULTILINE) var description


func _to_string():
	return "[STAT: "+name+"]"


func _ready():
	pass
