extends Node

var instance
var positions = {
	"TL": Vector2.ZERO,
	"TR": Vector2.ZERO,
	"BL": Vector2.ZERO,
	"BR": Vector2.ZERO,
}


var spawn_area
var spawn_shape
var despawn_area
var despawn_shape

func _ready():
	pass



func set_limits():
	var map_inst = WorldManager.instance

	var half_size = map_inst.map_size

	instance.limit_left = -32 * (half_size.x - 1)
	instance.limit_top = -32 * (half_size.y - 1)
	instance.limit_right = 32 * (half_size.x - 1)
	instance.limit_bottom = 32 * (half_size.y - 1)
