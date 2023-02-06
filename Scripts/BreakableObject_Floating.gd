extends BreakableObject


export (Vector2) var land_range


func _ready():
	._ready()
	var tile_idx = WorldManager.tile_at_position(global_position)
	var on_land = (tile_idx >= land_range.x  and  tile_idx <= land_range.y)
	$Graphic/AnimationTree.set("parameters/on_land/current", (0 if on_land else 1))
	pass
