extends Node2D

export var hazard : PackedScene
export var autostart : bool = true


func spawn():
	var spawned = hazard.instance()
	WorldManager.add_hazard(spawned)
	print("GLOBAL POS = ", global_position)
	spawned.position = self.global_position


func _ready():
	if  autostart:
		spawn()
