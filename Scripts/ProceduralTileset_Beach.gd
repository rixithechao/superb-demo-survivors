extends TileSet
tool

const WATER = 0
const SAND = 1
const GRASS = 2
const DARKGRASS = 3

var binds = {
	WATER: [],
	SAND: [GRASS],
	GRASS: [DARKGRASS],
	DARKGRASS: []
}


func _is_tile_bound(id, neighbour_id):
	if id in binds:
		return neighbour_id in binds[id]
	return false


