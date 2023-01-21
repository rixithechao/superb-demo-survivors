extends Label

export var header_path : NodePath
var header_node

func _process(_delta):
	if  header_path != null  and  header_node == null:
		header_node = get_node(header_path)
		
	if  header_node != null:
		text = header_node.text
		pass
