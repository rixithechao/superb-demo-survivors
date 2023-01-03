extends Node2D

export var stage_data : Resource

var points_all = [Vector2.ZERO]
var points_landmarks_special = []
var points_landmarks_normal = []
var points_breakables = []

var landmark_indices = []
var landmark_scenes = []
var breakables_scenes = []

var heatmap = {}

var rng = RandomNumberGenerator.new()
var opSimNoise = OpenSimplexNoise.new()



const LANDMARK_SAMPLE_MULT = 3



func loadLandmarkScenes():
	for i in range(stage_data.landmarks.size()):
		landmark_scenes[i] = load(stage_data.landmarks[i])

	for i in range(stage_data.breakables.size()):
		breakables_scenes[i] = load(stage_data.breakables[i])



func addLandmarkPoint(point_type_array):
	var candidates = []
	var furthest_dist = 0
	var closest_dist = 0

	# Generate the sample points
	candidates.clear()
	
	for j in range(1, points_all.size()*LANDMARK_SAMPLE_MULT + 1):
		candidates.append(
			Vector2(
				rng.randi_range(20,stage_data.map_size.x-20),
				rng.randi_range(20,stage_data.map_size.y-20)
			)
		)
	
	# pick the one with the longest distance from existing sample points
	furthest_dist = 0
	closest_dist = INF
	
	print("ALL=", points_all, "\nCANDIDATES=", candidates)
	
	var new_point = candidates[0]
	for j in range(candidates.size()-1):
		var this_candidate = candidates[j]
		var closest_landmark = points_all[0]
		var dist

		for k in range(points_all.size()-1):
			var this_landmark = points_all[k]
			if  this_landmark != null:
				dist = this_landmark.distance_squared_to ( this_candidate )
				if  dist < closest_dist:
					closest_dist = dist
					closest_landmark = this_landmark

		print(closest_landmark)

		if closest_dist > furthest_dist:
			new_point = this_candidate

	points_all.append(new_point)
	point_type_array.append(new_point)


func generateLandmarks():
	rng.randomize()
	
	# Special landmarks
	var num_special = stage_data.special_landmarks.size()
	
	if num_special > 0:
		for i in range(num_special-1):
			var pos = addLandmarkPoint(points_landmarks_special)
			var sc = load(stage_data.special_landmarks[i])
			var sc_spawned = sc.instance()
			sc_spawned.transform.position = pos

	# normal landmarks
	for i in range(num_special, stage_data.landmark_count-1):
		landmark_indices.append(randi() % (max(1, landmark_scenes.size()) as int))
		var pos = addLandmarkPoint(points_landmarks_normal)

	# breakables
	for i in range(200):
		var pos = addLandmarkPoint(points_breakables)
		
		#var sc = load(stage_data.landmarks[randi() % (max(1, breakables_scenes.size()) as int)])
		#var sc_spawned = sc.instance()
		#sc_spawned.transform.position = pos





func initNoise():
	opSimNoise.seed = randi()
	opSimNoise.period = stage_data.noise_period
	opSimNoise.octaves = stage_data.noise_octaves


func generateHeatMap():
	
	# Generate the heatmap image	
	var img_blit = Image.new()
	img_blit.load("res://Textures/tex_landmarkBlit.png")
	
	var img_points = Image.new()
	img_points.create(stage_data.map_size.x, stage_data.map_size.y, false, 5)
	
	var img_merged = Image.new()
	img_merged.create(stage_data.map_size.x, stage_data.map_size.y, false, 5)

	print(img_blit.get_format(), " ", img_points.get_format())

	img_points.lock()
	img_points.fill(Color.black)
	
	var points_landmarks_all = points_landmarks_normal.duplicate(false) + points_landmarks_special
	
	for v in points_landmarks_all:
		print(v)
		img_points.blend_rect(img_blit, Rect2(0,0,32,32), Vector2(v.x-16,v.y-16))
	
	img_points.unlock()
	
	print(" ")


	# Populate the heatmap grid
	var heatmap_script 
	match stage_data.tile_rule:
		null:
			heatmap_script = load("res://Scripts/Tile Rules/TileRule_Default.gd")
		_:
			heatmap_script = load(stage_data.tile_rule)

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
			
			if a != 0:
				print("(", x, ", ", y, "), a=", a, ", b=", b, ", chosen=", chosen)

	MapManager.heatmap_texture.create_from_image(img_merged)




# Called when the node enters the scene tree for the first time.
func _ready():
	$TileMap.z_index = VisualServer.CANVAS_ITEM_Z_MIN
	$TileMap.tile_set = stage_data.tileset
	loadLandmarkScenes()
	generateLandmarks()
	generateHeatMap()
	$TileMap.apply(stage_data, heatmap)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
