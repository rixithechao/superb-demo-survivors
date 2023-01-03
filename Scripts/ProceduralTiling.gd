extends TileMap

var generated = false


func apply(stage_data, heatmap):
	for i in heatmap:
		var heat = heatmap[i]
		var tileIdx = round(lerp(1,3,heat))
		set_cell (i.x-floor(0.5*stage_data.map_size.x), i.y-floor(0.5*stage_data.map_size.y), tileIdx)
		print(i, ", val=", heat, ", idx=", tileIdx)
