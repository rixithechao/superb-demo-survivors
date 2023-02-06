extends Node


var progress = Save_Progress.new()
var settings = Save_Settings.new()
var records = Save_Records.new()
var serac = Save_Serac.new()

onready var _bus_music := AudioServer.get_bus_index("Music")
onready var _bus_soundeffects := AudioServer.get_bus_index("SoundEffects")

var _character_map = {}
var _passive_map = {}
var _weapon_map = {}
var _stage_map = {}


func fill_map(map_table, all_array):
	for idx in range(all_array.size()):
		var val = all_array[idx]
		map_table[val] = idx

func load_data(file_name):
	if ResourceLoader.exists(file_name):
		return ResourceLoader.load(file_name)
	else:
		return null


func _ready():
	fill_map(_character_map, CharacterManager.all_characters)
	fill_map(_passive_map, EquipmentManager.all_passives)
	fill_map(_weapon_map, EquipmentManager.all_weapons)
	fill_map(_stage_map, StageManager.all_stages)


	# Load or initialize progress
	var loaded_progress = load_data(progress.get_save_path())
	if  loaded_progress is Save_Progress:
		progress = loaded_progress


	# Load or initialize settings
	var loaded_settings = load_data(settings.get_save_path())
	if  loaded_settings is Save_Settings:
		settings = loaded_settings
		
		# Apply settings
		OS.set_use_vsync(settings.vsync)
		OS.window_fullscreen = settings.fullscreen
		OS.set_window_size(Vector2(768, 432) * settings.screen_scale)
		OS.center_window()

		AudioServer.set_bus_volume_db(_bus_music, linear2db(settings.music_volume))
		AudioServer.set_bus_volume_db(_bus_soundeffects, linear2db(settings.sound_volume))

	else:
		# Default vsync is going to vary from computer to computer
		settings.vsync = OS.is_vsync_enabled()


	# Load or initialize records
	var loaded_records = load_data(records.get_save_path())
	if  loaded_records is Save_Records:
		records = loaded_records

	# Load or initialize serac data
	var loaded_serac = load_data(serac.get_save_path())
	if  loaded_serac is Save_Serac:
		serac = loaded_serac
