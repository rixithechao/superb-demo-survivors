extends Resource
class_name StageData


export(Vector2) var map_size = Vector2(900,600)
export var tileset : TileSet

export(Array, Resource) var landmarks
export(Array, Resource) var special_landmarks
export(Array, Resource) var breakables
export var landmark_count = 50

export var tile_rule : Script
export(Array, Resource) var waves
export(AudioStream) var music

export var noise_period = 20
export var noise_octaves = 5

func _ready():
	pass
