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

var heatmap = {}

var rng = RandomNumberGenerator.new()
var opSimNoise = OpenSimplexNoise.new()

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
			UIManager.load_screen_break(lerp(0, 0.2, i/total_count))

		for scene in stage_data.breakables:
			breakables_scenes.append(scene)
			i += 1
			UIManager.load_screen_break(lerp(0, 0.2, i/total_count))



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


func generateLandmarks():
	rng.randomize()
	
	var i_total = stage_data.landmark_count + stage_data.breakables_count
	
	
	# Special landmarks
	var num_special = stage_data.special_landmarks.size()
	
	if num_special > 0:
		points_landmarks_special.append(map_size_tile_offset)
		points_all.append(map_size_tile_offset)
		
		for i in range(num_special-1):
			var pos = addLandmarkPoint(points_landmarks_special)
			var sc = load(stage_data.special_landmarks[i])
			var sc_spawned = sc.instance()
			sc_spawned.transform.position = pos
			WorldManager.add_object(sc_spawned)
			
			UIManager.load_screen_break(lerp(0.2, 0.5, i/i_total))

	else:
		points_landmarks_normal.append(map_size_tile_offset)
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



func initNoise():
	opSimNoise.seed = randi()
	opSimNoise.period = stage_data.noise_period
	opSimNoise.octaves = stage_data.noise_octaves


func generateHeatMap():
	
	# Generate the heatmap image	
	var img_blit = []
	for i in range(0,4):
		var img = Image.new()
		img.load("res://Textures/tex_landmarkBlit_"+String(i)+".png")
		img_blit.append(img)
	
	
	var img_points = Image.new()
	img_points.create(stage_data.map_size.x, stage_data.map_size.y, false, 5)
	
	var img_merged = Image.new()
	img_merged.create(stage_data.map_size.x, stage_data.map_size.y, false, 5)

	#print(img_blit.get_format(), " ", img_points.get_format())

	img_points.lock()
	img_points.fill(Color.black)
	
	var points_landmarks_all = points_landmarks_normal.duplicate(false) + points_landmarks_special
	
	var i_blit = points_landmarks_all.size()
	var i_total = i_blit + stage_data.map_size.x
	var i = 0
	
	for v in points_landmarks_all:
		#print(v)
		img_points.blend_rect(img_blit[randi() % img_blit.size()], Rect2(0,0,32,32), Vector2(v.x-16,v.y-16))
		i += 1
		UIManager.load_screen_break(lerp(0.5, 0.8, i/i_total))
	
	img_points.unlock()
	
	#print(" ")


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
	img_points.lock()
	img_merged.lock()
	for x in range(stage_data.map_size.x):
		for y in range(stage_data.map_size.y):
			var pos = Vector2(x,y)
			var a = img_points.get_pixelv(pos).get_luminance()
			var b = 1.5*abs(opSimNoise.get_noise_2d(x,y))
			var chosen = heatmap_script.process(pos, a, b)
			heatmap[pos] = chosen
			img_merged.set_pixelv(pos, Color.from_hsv(0,0,chosen,1))
			#UIManager.load_screen_break(lerp(0.5, 0.8, 0.5))
	
			if a != 0:
				#print("(", x, ", ", y, "), a=", a, ", b=", b, ", chosen=", chosen)
				pass

		i += 1
		UIManager.load_screen_break(lerp(0.5, 0.8, (i+i_blit)/i_total))


	WorldManager.heatmap_texture.create_from_image(img_merged)




func generate():
	$TileMap.z_index = VisualServer.CANVAS_ITEM_Z_MIN
	map_size_tile_offset = Vector2(floor(0.5*stage_data.map_size.x), floor(0.5*stage_data.map_size.y))

	print("GENERATING MAP:\nLoading landmark scenes")
	UIManager.load_screen_break(0.0)
	loadLandmarkScenes()
	
	print("Generating landmarks")
	UIManager.load_screen_break(0.2)
	generateLandmarks()
	
	print("Generating Heatmap")
	UIManager.load_screen_break(0.5)
	generateHeatMap()
	
	print("Applying tiles")
	UIManager.load_screen_break(0.8)
	$TileMap.apply(stage_data, heatmap, map_size_tile_offset)
	
	print("Generation done!\n")
	UIManager.load_screen_break(1.0)
	StageManager.on_stage_generated()
	
	generated = true
	pass # Replace with function body.


func spawn_landmark(scene_idx, position):
	var scene = landmark_scenes[scene_idx]
	var spawned = scene.instance()
	spawned.position = position
	WorldManager.add_object(spawned)

	print("SPAWNING LANDMARK: pos = ", position, ", name = ", spawned.name, "\n")
	
	return spawned



func _process(_delta):
	
	if  not generated  or  PlayerManager.instance == null:
		return
	
	var dist_to_player
	
	for  i  in  range(points_landmarks_normal.size()):
		var point = points_landmarks_normal[i]
		var point_tile_space = point - map_size_tile_offset
		var point_world_space = point_tile_space*64 + Vector2(16,16)
		
		#print("CHECKING DISTANCE TO LANDMARK: ", point, ", ", point_tile_space, ", ", point_world_space)
		
		dist_to_player = (PlayerManager.instance.position - point_world_space).length()
		
		var node_exists = landmark_nodes.has(point)
		
		if  dist_to_player < 2048  and  not node_exists  and  landmark_indices.has(i):
			#print("SPAWNING LANDMARK: dist = ", dist_to_player, ", point = ", point_world_space, "\n")

			landmark_nodes[point] = spawn_landmark(landmark_indices[i], point_world_space)

		if  dist_to_player > 2048+256  and  node_exists:
			var node = landmark_nodes[point]
			print("DESPAWNING LANDMARK: ", node.name, "\n")

			node.unload()
			landmark_nodes.erase(point)

	pass
