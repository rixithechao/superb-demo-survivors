extends Node2D

export var centered : bool = true


func _process(_delta):
	if  PlayerManager.instance == null:
		return

	if  StageManager.started == false:
		self.queue_free()

	if  centered:
		position = PlayerManager.instance.position
	else:
		position = CameraManager.positions.TL


func spawn_stage_boss(enemy : PackedScene):
	var boss_data = BossData.new()
	boss_data.final = true
	boss_data.enemy = enemy
	EnemyManager.spawn_boss(boss_data)

func start_other_map_event(new_event : PackedScene):
	WorldManager.add_map_event(new_event.instance())

func set_random_rotation(path : NodePath = ""):
	var target_node = self
	if  path != "":
		target_node = get_node(path)
		
	target_node.rotation_degrees = rand_range(0,360)



func start_warning(this_node_path : NodePath):
	var node = get_node(this_node_path)
	if  node != null:
		node.start()

func start_warnings(node_paths : Array, delay : float = 0.0, randomized : bool = false):
	var path_list = node_paths
	if  randomized:
		path_list.shuffle()
	
	for  node_path in path_list:
		start_warning(node_path)
		if  delay > 0.0:
			yield(get_tree().create_timer(delay), "timeout")


func toggle_regular_spawns(active : bool = false):
	StageManager.toggle_regular_spawns(active)

func clear_stage():
	StageManager.clear_stage()



func _on_AnimationPlayer_animation_finished(anim_name):
	if  anim_name == "Sequence_MapEvent":
		self.queue_free()
	pass # Replace with function body.
