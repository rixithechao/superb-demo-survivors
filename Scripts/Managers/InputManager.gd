extends Control


var _cached_focus_node


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS


func _input(event : InputEvent) -> void:

	if (event is InputEventMouseMotion):
		if  Input.mouse_mode == Input.MOUSE_MODE_CAPTURED  and  event.relative.length() > 0.5:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	elif  not (event is InputEventMouseButton):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	else:
		pass


func _process(_delta):
	if _cached_focus_node != get_focus_owner():
		_cached_focus_node = get_focus_owner()
		print ("\nFOCUS CHANGED: ", _cached_focus_node, "\n")
