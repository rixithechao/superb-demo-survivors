extends Node2D


func _process(_delta):
	if  PlayerManager.instance == null:
		return

	if  StageManager.started == false:
		self.queue_free()

	position = PlayerManager.instance.position



func set_random_rotation():
	rotation_degrees = rand_range(0,360)



func start_warning(this_node_path : NodePath):
	var node = get_node(this_node_path)
	if  node != null:
		node.start()



func _on_AnimationPlayer_animation_finished(anim_name):
	if  anim_name == "Sequence_MapEvent":
		self.queue_free()
	pass # Replace with function body.
