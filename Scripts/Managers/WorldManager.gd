extends Node

var heatmap_texture = ImageTexture.new()
var viewport_texture = ImageTexture.new()

var instance
var world_objects_node
var map_events_node
var tilemap_node
var terrain_node
var hazards_node

var _blit_images = []
var _blit_textures = []


# For the eventual blue noise multithreading
var points_all = [Vector2.ZERO]
var points_landmarks_special = []
var points_landmarks_normal = []
var points_breakables = []

var landmark_indices = []

var blue_noise_thread

const LANDMARK_SAMPLE_MULT = 1





func add_node_to_world_stack(node, stack):
	var parnt = node.get_parent()
	if  parnt != null:
		parnt.remove_child(node)
	#stack.set_deferred("add_child", node)
	stack.add_child(node)
	pass

func add_object(node):
	add_node_to_world_stack(node, world_objects_node)

func add_map_event(node):
	add_node_to_world_stack(node, map_events_node)

func add_hazard(node):
	add_node_to_world_stack(node, hazards_node)

func tile_to_world(coord):
	var local_position = tilemap_node.map_to_world(coord)
	return tilemap_node.to_global(local_position)


func tile_at_position(global_coord):
	var local_coord = tilemap_node.to_local(global_coord)
	var tile_coord = tilemap_node.world_to_map(local_coord)
	return tilemap_node.get_cellv(tile_coord)






func addLandmarkPoint(point_type_array, map_size, rng):
	var candidates = []
	var furthest_dist = 0
	var closest_dist = 0

	# Generate the sample points
	candidates.clear()
	
	for _j in range(1, points_all.size()*LANDMARK_SAMPLE_MULT + 1):
		candidates.append(
			Vector2(
				rng.randi_range(20,map_size.x-20),
				rng.randi_range(20,map_size.y-20)
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




func _blue_noise_calc(stage_data):
	var rng = RandomNumberGenerator.new()
	rng.randomize()

	var i_total = stage_data.landmark_count + stage_data.breakables_count


	# Special landmarks
	var num_special = stage_data.special_landmarks.size()

	if num_special > 0:

		# Spawn the first at the center of the map
		points_landmarks_special.append(stage_data.half_map_size)
		var home_lm = stage_data.special_landmarks[0]
		var home_lm_spawned = home_lm.instance()
		home_lm_spawned.position = Vector2.ZERO
		WorldManager.add_object(home_lm_spawned)

		points_all.append(stage_data.half_map_size)


		# Spawn the others in random locations around the map
		if  num_special > 1:
			for i in range(1,num_special-1):
				var pos = addLandmarkPoint(points_landmarks_special, stage_data.map_size, rng)
				var sc = stage_data.special_landmarks[i]
				var sc_spawned = sc.instance()
				sc_spawned.position = WorldManager.tile_to_world(pos - stage_data.half_map_size)
				WorldManager.add_object(sc_spawned)

				#print ("SPECIAL LANDMARK ", i, " AT ", pos, "/", sc_spawned.global_position)

				call_deferred("_report_blue_noise_progress", i/i_total)


	# If no special landmarks exist, spawn a normal landmark at the center of the map
	else:
		points_landmarks_normal.append(stage_data.half_map_size)
		landmark_indices.append(randi() % (max(1, stage_data.num_landmarks) as int))
		points_all.append(stage_data.half_map_size)


	# normal landmarks; need to eventually replace landmark_count and breakables_count with numbers calculated based on density
	for _i in range(num_special, stage_data.landmark_count-1):
		landmark_indices.append(randi() % (max(1, stage_data.num_landmarks) as int))
		addLandmarkPoint(points_landmarks_normal, stage_data.map_size, rng)
		UIManager.load_screen_break(lerp(0.2, 0.5, _i/i_total))


	# breakables
	for _i in range(stage_data.breakables_count):
		addLandmarkPoint(points_breakables, stage_data.map_size, rng)

		UIManager.load_screen_break(lerp(0.2, 0.5, (_i+stage_data.landmark_count)/i_total))

	print ("SPECIAL LANDMARKS: ", stage_data.special_landmarks, points_landmarks_special, "\nNORMAL LANDMARKS: ", stage_data.landmarks, points_landmarks_normal, "\nBREAKABLES: ", stage_data.breakables, points_breakables, "\n")

	pass

func _report_blue_noise_progress(percent):
	pass


func generate_blue_noise(input):

	blue_noise_thread = Thread.new()
	blue_noise_thread.start(self, "_blue_noise_calc", input)
	
	blue_noise_thread.wait_to_finish()

func return_blue_noise(output):
	
	pass





func _ready():
	for i in range(0,5):
		var tex = load("res://Textures/tex_landmarkBlit_"+String(i)+".png")
		var img = tex.get_data()
		_blit_textures.append(tex)
		_blit_images.append(img)
	pass
