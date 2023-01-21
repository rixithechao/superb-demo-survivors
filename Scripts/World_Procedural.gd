extends "res://Scripts/World.gd"


export(Vector2) var map_size = Vector2(400,400)

export(Array, Resource) var landmarks
export(Array, Resource) var special_landmarks
export(Array, Resource) var breakables
export var landmark_count = 50
export var breakables_count = 200

export var tile_rule : Script

export var noise_period = 20
export var noise_octaves = 5




func _ready():
	._ready()
	$Terrain.generate()
	pass
