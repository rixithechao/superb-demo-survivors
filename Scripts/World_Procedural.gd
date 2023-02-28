extends "res://Scripts/World.gd"
class_name World_Procedural

export(Array, PackedScene) var landmarks
export(Array, PackedScene) var special_landmarks
export(Array, PackedScene) var breakables
export var landmark_count = 50
export var breakables_count = 200

export var tile_rule : Script

export var noise_period = 60
export var noise_octaves = 9




func _ready():
	._ready()
	$Terrain.generate()
	pass
