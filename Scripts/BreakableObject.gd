extends HarmableCharacter
class_name BreakableObject

export (int) var max_hp = 30
export (Resource) var drop_table


func die(prevent_drops: bool = false):
	$Collision.set_deferred("disabled", true)
	set_collision_layer_bit ( 8, false )
	set_collision_mask_bit ( 1, false )
	.die(prevent_drops)


func _ready():
	_max_hp = max_hp
	_drop_table = drop_table


func unload():
	self.queue_free()
