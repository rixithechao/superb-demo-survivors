extends BreakableObject

enum ForcedState {
	WATER,
	LAND,
	AUTO
}

export (ForcedState) var forced_state = ForcedState.AUTO
export (Vector2) var land_range


func _ready():
	._ready()
	var tile_idx = WorldManager.tile_at_position(global_position)
	var on_land = (tile_idx >= land_range.x  and  tile_idx <= land_range.y)
	var applied_state = (forced_state if (forced_state != ForcedState.AUTO) else on_land)
	
	$Graphic/AnimationTree.set("parameters/on_land/current", (0 if applied_state else 1))
	pass
