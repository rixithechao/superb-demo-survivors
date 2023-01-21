extends Node2D


export(AudioStream) var music
export(Color) var tint = Color.white


func _ready():
	WorldManager.instance = self
	WorldManager.world_objects_node = $WorldObjects
	WorldManager.map_events_node = $MapEvents
	StageManager.on_stage_loaded()


func _process(delta):
	if get_node("Terrain/TileMap") != null and tint != null:
		$Terrain/TileMap.modulate = tint
	pass


func start_sequence(name):
	$SequenceAnimation.play(name)

func start_stage():
	StageManager.start_stage()
