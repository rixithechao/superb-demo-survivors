extends Node2D


var generated = false

var points_all = [Vector2.ZERO]
var points_landmarks_special = []
var points_landmarks_normal = []
var points_breakables = []

var landmark_indices = []
var landmark_scenes = []
var breakables_scenes = []

var landmark_nodes = {}
var breakable_nodes = {}

var img_vp
var heatmap = {}

var rng = RandomNumberGenerator.new()
var opSimNoise

var map_size_tile_offset



onready var stage_data = $".."


const LANDMARK_SAMPLE_MULT = 1



func loadLandmarkScenes():
	var total_count = stage_data.landmarks.size() + stage_data.breakables.size()
	
	if  total_count > 0:
		var i = 0
		
		for scene in stage_data.landmarks:
			landmark_scenes.append(scene)
			i += 1
			UIManager.load_screen_break(lerp(0.05, 0.2, i/total_count))
		
		print("landmark scene array: ", landmark_scenes)

		for scene in stage_data.breakables:
			breakables_scenes.append(scene)
			i += 1
			UIManager.load_screen_break(lerp(0.05, 0.2, i/total_count))

		print("breakables scene array: ", breakables_scenes, "\n")




# based on the process described in https://blog.demofox.org/2017/10/20/generating-blue-noise-sample-points-with-mitchells-best-candidate-algorithm/
# just the process, not the code at the bottom of the page.  I get overwhelmed trying to read C++ lol


func addLandmarkPoint(point_type_array):
	var candidates = []
	var furthest_dist = 0
	var closest_dist = 0

	# Generate the sample points
	candidates.clear()
	
	for _j in range(1, points_all.size()*LANDMARK_SAMPLE_MULT + 1):
		candidates.append(
			Vector2(
				rng.randi_range(20,stage_data.map_size.x-20),
				rng.randi_range(20,stage_data.map_size.y-20)
			)
		)
	
	# pick the one with the longest distance from existing sample points
	# as far as I can follow this _should_ be right...?  But the problem is most likely here.
	furthest_dist = 0
		
	#print("EXISTING=", points_all, "\nCANDIDATES=", candidates, "\n")
	
	var new_point = candidates[0]
	for j in range(candidates.size()):
		var this_candidate = candidates[j]
		closest_dist = points_all[0].distance_squared_to ( candidates[j] )

		for k in range(points_all.size()):
			var this_landmark = points_all[k]
			if  this_landmark != null:
				var dist = this_landmark.distance_squared_to ( this_candidate )
				#print("CANDIDATE = ", this_candidate, ", LANDMARK = ", this_landmark, ", DIST=", dist)
				if  dist < closest_dist:
					#print (k,": This existing point is closer to the candidate!\n", dist, " < ", closest_dist, "\n")
					closest_dist = dist
			else:
				#print("null landmark!\n")
				pass

		if closest_dist > furthest_dist:
			#print (j, ": This candidate is further from any existing points than all prior candidates!")
			new_point = this_candidate
			#print("new point=", new_point, ", ", closest_dist, " > ", furthest_dist, "\n")
			furthest_dist = closest_dist
		else:
			#print (j, ": This candidate is not as far. (", closest_dist, ")")
			pass

	#print("FINAL POINT: ", new_point, ", FINAL DISTANCE: ", furthest_dist, "\n")

	points_all.append(new_point)
	point_type_array.append(new_point)
	
	return new_point


func generateLandmarks():
	rng.randomize()
	
	var i_total = stage_data.landmark_count + stage_data.breakables_count
	
	
	# Special landmarks
	var num_special = stage_data.special_landmarks.size()
	
	if num_special > 0:

		# Spawn the first at the center of the map
		points_landmarks_special.append(map_size_tile_offset)
		var home_lm = stage_data.special_landmarks[0]
		var home_lm_spawned = home_lm.instance()
		home_lm_spawned.position = Vector2.ZERO
		WorldManager.add_object(home_lm_spawned)

		points_all.append(map_size_tile_offset)


		# Spawn the others in random locations around the map
		if  num_special > 1:
			for i in range(1,num_special):
				var pos = addLandmarkPoint(points_landmarks_special)
				var sc = stage_data.special_landmarks[i]
				var sc_spawned = sc.instance()
				sc_spawned.position = WorldManager.tile_to_world(pos - map_size_tile_offset)
				sc_spawned.add_to_group("landmark_special")
				WorldManager.add_object(sc_spawned)
				
				#print ("SPECIAL LANDMARK ", i, " AT ", pos, "/", sc_spawned.global_position)
				
				UIManager.load_screen_break(lerp(0.2, 0.5, i/i_total))


	# If no special landmarks exist, spawn a normal landmark at the center of the map
	else:
		points_landmarks_normal.append(map_size_tile_offset)
		landmark_indices.append(randi() % (max(1, landmark_scenes.size()) as int))
		points_all.append(map_size_tile_offset)


	# normal landmarks; need to eventually replace landmark_count and breakables_count with numbers calculated based on density
	for _i in range(num_special, stage_data.landmark_count-1):
		landmark_indices.append(randi() % (max(1, landmark_scenes.size()) as int))
		addLandmarkPoint(points_landmarks_normal)
		UIManager.load_screen_break(lerp(0.2, 0.5, _i/i_total))


	# breakables
	for _i in range(stage_data.breakables_count):
		addLandmarkPoint(points_breakables)

		UIManager.load_screen_break(lerp(0.2, 0.5, (_i+stage_data.landmark_count)/i_total))

	print ("SPECIAL LANDMARKS: ", stage_data.special_landmarks, points_landmarks_special, "\nNORMAL LANDMARKS: ", stage_data.landmarks, points_landmarks_normal, "\nBREAKABLES: ", stage_data.breakables, points_breakables, "\n")


func initNoise():
	opSimNoise = $Noise.texture.noise
	opSimNoise.seed = randi()
	opSimNoise.period = stage_data.noise_period
	opSimNoise.octaves = stage_data.noise_octaves


func generateViewport():
	# Generate the heatmap image	
	var blit_imgs = WorldManager._blit_images
	var blit_texs = WorldManager._blit_textures
	#print("BLIT TEXTURES: ", blit_imgs, ", ", blit_texs)
	
	#&var img_points = Image.new()
	#&img_points.create(stage_data.map_size.x, stage_data.map_size.y, false, 5)
	
	#print(blit_imgs.get_format(), " ", img_points.get_format())

	#&img_points.lock()
	#&img_points.fill(Color.black)
	
	var points_landmarks_all = points_landmarks_normal.duplicate(false) + points_landmarks_special
	
	var i_total = points_landmarks_all.size()
	var i = 0

	$Viewport.size = stage_data.map_size

	for v in points_landmarks_all:
		#print(v)
		#var this_blit_img = blit_imgs[randi() % blit_imgs.size()]
		var this_blit_tex = blit_texs[randi() % blit_imgs.size()]
		var this_blit_rect = TextureRect.new()
		var this_blit_pos = Vector2(v.x-16,v.y-16)

		this_blit_rect.	pause_mode = Node.PAUSE_MODE_PROCESS
		this_blit_rect.set_texture(this_blit_tex)
		this_blit_rect.rect_size = Vector2(32,32)
		$Viewport.add_child(this_blit_rect)
		this_blit_rect.rect_position = this_blit_pos

		#print("THIS BLIT AFTER: ", this_blit_tex, ", ", this_blit_rect.texture)

		#&img_points.blend_rect(this_blit_img, Rect2(0,0,32,32), this_blit_pos)
		i += 1
		UIManager.load_screen_break(lerp(0.5, 0.65, i/i_total))
	
	#&img_points.unlock()
	yield(get_tree(), "idle_frame")
	VisualServer.force_draw()

	WorldManager.viewport_texture = $Viewport.get_texture()
	img_vp = WorldManager.viewport_texture.get_data()
	#img_vp.flip_y()
	img_vp.lock()
	#print(" ")



func generateHeatMap():

	# Populate the heatmap grid
	var heatmap_script 
	match stage_data.tile_rule:
		null:
			heatmap_script = load("res://Scripts/Tile Rules/TileRule_Default.gd")
		_:
			print("STAGE: ", stage_data.name, ", TILE RULE: ", stage_data.tile_rule)
			heatmap_script = stage_data.tile_rule
			pass

	initNoise()
	#&img_points.lock()

	var i_total = stage_data.map_size.x
	var i = 0

	var img_merged = Image.new()
	img_merged.create(stage_data.map_size.x, stage_data.map_size.y, false, 5)
	
	img_merged.lock()
	for x in range(stage_data.map_size.x):
		for y in range(stage_data.map_size.y):
			var pos = Vector2(x,y)
			var a = img_vp.get_pixelv(pos).get_luminance()
			var b = 1.5*abs(opSimNoise.get_noise_2d(x,y))
			var chosen = heatmap_script.process(pos, a, b)
			heatmap[pos] = chosen
			#img_merged.set_pixelv(pos, Color.from_hsv(0,0,chosen,1))
			#UIManager.load_screen_break()

			if chosen > 0.6:
				#print("(", x, ", ", y, "), a=", a, ", b=", b, ", chosen=", chosen)
				pass

		#i += 1
		UIManager.load_screen_break(lerp(0.65, 0.8, i/i_total))

	#print("HEATMAP: ", heatmap)
	#WorldManager.heatmap_texture.create_from_image(img_merged)




func generate():
	WorldManager.terrain_node = self
	
	$TileMap.z_index = VisualServer.CANVAS_ITEM_Z_MIN
	map_size_tile_offset = Vector2(floor(0.5*stage_data.map_size.x), floor(0.5*stage_data.map_size.y))

	print("GENERATING MAP:\nLoading landmark scenes")
	UIManager.load_screen_break(0.05)
	loadLandmarkScenes()

	yield(get_tree().create_timer(0.05), "timeout")
	
	print("Generating landmarks")
	UIManager.load_screen_break(0.2)
	generateLandmarks()

	yield(get_tree().create_timer(0.05), "timeout")

	print("Generating Viewport")
	UIManager.load_screen_break(0.5)
	generateViewport()

	yield(get_tree().create_timer(0.05), "timeout")

	print("Generating Heatmap")
	UIManager.load_screen_break(0.65)
	generateHeatMap()

	yield(get_tree().create_timer(0.05), "timeout")

	print("Applying tiles")
	UIManager.load_screen_break(0.8)
	$TileMap.apply(stage_data, heatmap, map_size_tile_offset)

	yield(get_tree().create_timer(0.05), "timeout")

	print("Generation done!\n")
	UIManager.load_screen_break(1.0)
	StageManager.on_stage_generated()
	
	generated = true
	pass # Replace with function body.


func spawn_landmark(scene_idx, pos):
	var scene = landmark_scenes[scene_idx]
	var spawned = scene.instance()
	spawned.global_position = pos
	WorldManager.add_object(spawned)

	print("SPAWNING LANDMARK: pos = ", position, ", name = ", spawned.name, "\n")
	
	return spawned


func spawn_breakable(pos):
	var scene = breakables_scenes[randi() % breakables_scenes.size()]
	var spawned = scene.instance()
	spawned.global_position = pos
	WorldManager.add_object(spawned)

	#print("SPAWNING BREAKABLE: pos = ", position, ", name = ", spawned.name, "\n")
	
	return spawned
	


var funcref_landmark = funcref(self, "spawn_landmark")
var funcref_breakable = funcref(self, "spawn_breakable")


func handle_proximity_spawning(func_spawn: FuncRef, point_list: Array, node_table: Dictionary, max_distance: float = 2048, object_string: String = "LANDMARK", index_list = null):

	if  PlayerManager.instance == null:
		return

	var dist_to_player
	
	for  i  in  range(point_list.size()):
		var point = point_list[i]
		var point_world_space = WorldManager.tile_to_world(point - map_size_tile_offset)
		
		#print("CHECKING DISTANCE TO " + object_string + ": ", point, ", ", point_world_space)
		
		dist_to_player = (PlayerManager.instance.position - point_world_space).length()
		
		var node_exists = node_table.has(point)
		
		if  dist_to_player < max_distance  and  not node_exists:
			if  index_list == null  or  (index_list.size() > i  and index_list[i] >= 0):
				print("SPAWNING ", object_string, ": dist = ", dist_to_player, ", texture space = ", point, ", tile_space = ", point-map_size_tile_offset, ", world space = ", point_world_space, "\n")

				if  index_list != null:
					node_table[point] = func_spawn.call_func(index_list[i], point_world_space)
				else:
					node_table[point] = func_spawn.call_func(point_world_space)

			else:
				print("CAN'T SPAWN ", object_string, ":\n")
				if  index_list != null:
					print("i=", i, ", index list size = ", index_list.size())
					pass
				pass
			


		if  dist_to_player > max_distance+256  and  node_exists:
			var node = node_table[point]
			if  is_instance_valid(node):
				print("DESPAWNING " + object_string + ": ", node.name, "\n")

				node.unload()
				# warning-ignore:return_value_discarded
			node_table.erase(point)




func _process(_delta):
	
	if  not generated  or  PlayerManager.instance == null:
		return

	# Landmark loading/unloading
	if  points_landmarks_normal.size() > 0:
		handle_proximity_spawning(funcref_landmark, points_landmarks_normal, landmark_nodes, 2048, "LANDMARK", landmark_indices)
	
	# Breakable object spawning
	if  points_breakables.size() > 0:
		handle_proximity_spawning(funcref_breakable, points_breakables, breakable_nodes, 2048, "BREAKABLE")
