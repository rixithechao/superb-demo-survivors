extends Node2D


export(Color) var tint = Color.white
export(Vector2) var map_size = Vector2(400,400)


func _ready():
	WorldManager.instance = self
	WorldManager.world_objects_node = $WorldObjects
	WorldManager.map_events_node = $MapEvents
	WorldManager.tilemap_node = $Terrain/TileMap
	WorldManager.hazards_node = $Hazards
	StageManager.on_stage_loaded()


func _process(_delta):
	if get_node("Terrain/TileMap") != null and tint != null:
		$Terrain/TileMap.modulate = tint
	pass



func call_menu(name : String):
	MenuManager.queue(name)
	pass

func post_death_menu():
	MenuManager.open("deathbg")

	var signal_data = {"cancelled": (not PlayerManager.show_serac)  and  PlayerManager.coins < PlayerManager.get_revive_cost()}
	
	print ("REVIVE CHECK SIGNAL DATA BEFORE: ", signal_data)
	PlayerManager.emit_signal("revive_check", signal_data)
	print ("REVIVE CHECK SIGNAL DATA AFTER: ", signal_data)

	if  not signal_data.cancelled:
		MenuManager.open("revive")
		PlayerManager.show_serac = false
	else:
		MenuManager.open("gameover")

func restart_stage():
	StageManager.restart_stage()

func clear_stage():
	MenuManager.open("deathbg")
	MenuManager.open("gameover")




func start_sequence(name : String):
	$SequenceAnimation.play(name)

func prompt_change_character():
	StageManager.prompt_change_character()

func spawn_player():
	StageManager.spawn_player()

func start_stage():
	StageManager.start_stage()
