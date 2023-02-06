extends TileMap

var generated = false



func apply(_stage_data, heatmap, map_size_offset):

	var i_total = heatmap.size()
	var _i = 0
	
	for i in heatmap:
		var heat = heatmap[i]
		var tileIdx = round(lerp(0,3,heat))
		set_cell (i.x-map_size_offset.x, i.y-map_size_offset.x, tileIdx)
		#print(i, ", val=", heat, ", idx=", tileIdx)
		_i += 1
		if _i % 200 == 0:
			UIManager.load_screen_break(lerp(0.8, 1.0, _i/i_total))
	
	update_bitmask_region(-map_size_offset, map_size_offset )
