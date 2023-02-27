extends Node

var all_stages = [
	preload("res://Data Objects/Stages/Stage_Debug.tres"),
	preload("res://Data Objects/Stages/Stage_Islands.tres")
]

var grouped_stages = {
	"normal": [
		all_stages[1]
	],
	"special": [
		
	],
	"debug": all_stages[0]
}
var unlocked = []


var started = false
var cleared = false
var exiting = false

var regular_spawns_active = true

var faded_stage_music = false

var current_wave = -1
var current_wave_data
var current_stage_data
var current_wave_minimum = 1
var spawn_data = []
var current_map_events = {}

var instance



signal stage_loaded
signal stage_generated
signal stage_cleared
signal stage_exited
signal stage_restarted



# Stage select
func update_unlocked_list():
	unlocked.clear()
	
	if  OS.is_debug_build():
		unlocked.append(grouped_stages.debug)
	
	# Add each normal stage based on clearing the previous one
	for idx in range(grouped_stages.normal.size()):
		if idx == 0  or  SaveManager.progress.normal_stage_clears.has(idx-1):
			unlocked.append(grouped_stages.normal[idx])




# Inside stage
func init_stage():
	started = false
	
	# Reset wave info and spawning
	current_wave = -1
	current_wave_data = null
	current_map_events.clear()
	regular_spawns_active = true

	# Set time to 0
	TimeManager.reset_timer()
	
	# Reset player
	PlayerManager.reset_player()
	
	# Reset enemy-related stuff
	EnemyManager.init_stage_enemies()
	EnemyManager.kills = 0



func prompt_change_character():
	if  PlayerManager.show_character_select:
		MenuManager.open("character")
	else:
		controls_or_spawn_player()

func controls_or_spawn_player():
	if  SaveManager.progress.seen_controls_prompt:
		spawn_player()
	else:
		SaveManager.progress.seen_controls_prompt = true
		SaveManager.progress.save()
		WorldManager.instance.start_sequence("Sequence_ControlsPrompt")

func spawn_player():
	PlayerManager.spawn()
	WorldManager.instance.start_sequence("Sequence_SpawnPlayer")

func start_stage():
	regular_spawns_active = true
	faded_stage_music = false
	started = true
	cleared = false
	exiting = false

	MusicManager.play(current_stage_data.music_data)
	print("STAGE STARTED\n")
	_on_change_minute()


func restart_stage():
	TimeManager.remove_pause("restarting")
	TimeManager.remove_pause("revive")
	
	for mangr in [EnemyManager, ProjectileManager, PickupManager, MapEventManager, WarningManager]:
		mangr.erase_all()
	PlayerManager.unload_player()
	init_stage()

	emit_signal("stage_restarted")

	WorldManager.instance.start_sequence("Sequence_Start")
	pass

func clear_stage():
	cleared = true
	
	var signal_data = {"cancelled": false}
	emit_signal("stage_cleared", signal_data)
	if  not signal_data.cancelled:
		WorldManager.instance.start_sequence("Sequence_Clear")


func begin_restarting(prompt_character_change : bool = false):
	if  prompt_character_change:
		print ("BEGIN CHANGING CHARACTER")
	else:
		print ("BEGIN RESTART")

	if  MusicManager.current_track != current_stage_data.music_data:
		MusicManager.fade_out(1)

	TimeManager.add_pause("restarting")
	PlayerManager.show_character_select = prompt_character_change
	WorldManager.instance.start_sequence("Sequence_Restart")
	pass

func keep_going():
	pass

func toggle_regular_spawns(value):
	regular_spawns_active = value




func load_stage(stage_data):
	print(stage_data, "\nname=", stage_data.name, "\nscene=", stage_data.scene, "\n")
	current_stage_data = stage_data
	var loaded_scene = stage_data.scene
	instance = loaded_scene.instance()
	RootManager.stage.add_child(instance)

func exit_stage():
	exiting = true
	started = false
	TimeManager.add_pause("exiting")
	MusicManager.fade_out(1)
	UIManager.show_load_screen()
	UIManager.connect("load_screen_faded_in", self, "on_load_screen_faded_in")
	pass



func on_load_screen_faded_in():
	if  exiting:
		emit_signal("stage_exited")
		exiting = false
		TimeManager.remove_pause("exiting")
		instance.queue_free()
		UIManager.load_screen_instance.finish()
		MenuManager.open("title")



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
	if  spawn_data.size() > 0:
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
	spawned.position = position
	WorldManager.add_object(spawned)
	return spawned



func _on_change_second():
	var one_sec = TimeManager.get_seconds_passed()

	if current_map_events.has(one_sec):
		var events_array = current_map_events[one_sec]
		for  mev in events_array:
			if  mev.conditions == null  or  mev.conditions.evaluate():
				WorldManager.add_map_event(mev.event_scene.instance())

	# Fade music out in anticipation of the boss
	if  not  faded_stage_music  and  one_sec >= 56  and  TimeManager.get_minutes_passed() == current_stage_data.boss_minute - 1:
		faded_stage_music = true
		MusicManager.fade_out(3)
	

func _on_change_minute():
	current_map_events.clear()
	current_wave = TimeManager.get_minutes_passed()

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

	# Enemy spawning
	if  cleared  or  not regular_spawns_active:
		return

	for entry in spawn_data:
		entry.timer -= delta*TimeManager.time_rate*PlayerManager.get_stat(StatsManager.SPAWN_RATE)
		if entry.timer <= 0:
			var data = entry.data
			var count = EnemyManager.count
			if count < 300:
				EnemyManager.spawn(data.enemies[randi() % data.enemies.size()])

			entry.timer += data.interval

