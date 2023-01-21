extends Node

var stages = [
	preload("res://Data Objects/Stages/Stage_Test.tres"),
	preload("res://Data Objects/Stages/Stage_Debug.tres"),
]


signal stage_loaded
signal stage_generated



var started = false
var current_wave = -1
var current_wave_data
var current_stage_data
var current_wave_minimum = 1
var spawn_data = []
var current_map_events = {}


func init_stage():
	PlayerManager.reset_player()
	EnemyManager.init_stage_enemies()



func start_stage():
	started = true
	_on_change_minute()



func load_stage(stage_data):
	print(stage_data, "\nname=", stage_data.name, "\nscene=", stage_data.scene, "\n")
	current_stage_data = stage_data
	var loaded_scene = stage_data.scene
	var inst = loaded_scene.instance()
	RootManager.stage.add_child(inst)


func on_stage_loaded():
	emit_signal("stage_loaded")
	init_stage()
	pass

func on_stage_generated():
	emit_signal("stage_generated")
	UIManager.finish_load_screen()
	WorldManager.instance.start_sequence("Sequence_Start")
	pass



func start_wave(wave):
	
	# Boss spawns
	if wave.bosses.size() > 0:
		for boss in wave.bosses:
			EnemyManager.spawn_boss(boss)
	
	# Regular enemy spawns
	current_wave_minimum = wave.minimum
	spawn_data.clear()
	for spawn in wave.enemy_spawns:
		spawn_data.append({"data":spawn, "timer":spawn.delay})

	var count = EnemyManager.count
	while (count < current_wave_minimum):
		count = EnemyManager.count
		for entry in spawn_data:
			var data = entry.data
			EnemyManager.spawn(data.enemies[randi() % data.enemies.size()])

	# Map events
	current_map_events.clear()
	for mev in wave.map_events:
		if  not current_map_events.has(mev.second):
			current_map_events[mev.second] = []
		current_map_events[mev.second].append(mev)



func spawn_pickup(pickup_data, position):
	var spawned = pickup_data.instance()
	WorldManager.add_object(spawned)
	spawned.position = position



func _on_change_second():
	var one_sec = TimeManager.get_seconds_passed()
	
	if current_map_events.has(one_sec):
		var events_array = current_map_events[one_sec]
		for  mev in events_array:
			if  mev.conditions == null  or  mev.conditions.evaluate():
				WorldManager.add_map_event(mev.event_scene.instance())
	pass

func _on_change_minute():
	current_map_events.clear()
	current_wave += 1
	if current_wave < current_stage_data.waves.size():
		current_wave_data = current_stage_data.waves[current_wave]
		start_wave(current_wave_data)


func _ready():
	TimeManager.connect("new_minute", self, "_on_change_minute")
	TimeManager.connect("new_second", self, "_on_change_second")
	pass


func _process(delta):
	if not started or TimeManager.is_paused:
		return
	
	for entry in spawn_data:
		entry.timer -= delta*TimeManager.time_rate
		if entry.timer <= 0:
			var data = entry.data
			var count = EnemyManager.count
			if count < 300:
				EnemyManager.spawn(data.enemies[randi() % data.enemies.size()])

			entry.timer += data.interval

