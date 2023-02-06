extends Resource
class_name SaveableData



func get_save_path():
	return "user://save_data.res"


func save():
	var result = ResourceSaver.save(get_save_path(), self)
	assert(result == OK)
