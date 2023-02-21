extends Resource
class_name StageData

export var name : String
export var preview : Texture
export var scene : Resource
export var tint : Color
export var music_data : Resource
export var boss_music_data : Resource
export(Array, Resource) var waves
export var boss_minute : int = 15
export var reaper_minute : int = 20


func _ready():
	pass
