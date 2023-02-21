extends Equipment
class_name Equipment_Spawner

export (Array, PackedScene) var projectile_prefabs
export var pool_limit : int = 30

var timer_projectiles = 0
var timer_cooldown = 0
var projectiles_left = 9999

var spawned_objects = []



func pick_prefab():
	return projectile_prefabs[randi() % projectile_prefabs.size()]




func spawn(volley_index = 0):
	if  spawned_objects.size() >= pool_limit:
		return
	
	var spawned = pick_prefab().instance()
	spawned.volley_index = volley_index
	spawned.weapon_data = data

	WorldManager.add_object(spawned)
	spawned.position = PlayerManager.instance.position
	spawned_objects.append(spawned)




func on_setup():
	var current_stats = get_stats()
	
	timer_projectiles = 0
	timer_cooldown = current_stats[StatsManager.COOLDOWN]
	projectiles_left = current_stats[StatsManager.AMOUNT]-1

func on_process_equipment(delta):
	#print("Equipment processing for ", name)

	# Track spawned projectiles
	for i in range(spawned_objects.size()-1, -1, -1):
		var inst = spawned_objects[i]
		if  not is_instance_valid(inst):
			spawned_objects.erase(inst)

	# Iterate timers
	timer_projectiles = max(0, timer_projectiles - delta)
	timer_cooldown = max(0, timer_cooldown - delta)
	
	var current_stats = get_stats()
	#print ("FINAL WEAPON STATS: ", current_stats)
	
	if timer_projectiles <= 0  and  projectiles_left > 0:
		projectiles_left -= 1
		timer_projectiles = current_stats[StatsManager.SHOT_INTERVAL]
		spawn(projectiles_left)

		#print("PROJECTILE FIRED: ", wpnData.name,"\n", tbl, "\n\n", wpnData.stats.apply_stats({}), "\n\n", current_stats, "\n")


	if  timer_cooldown <= 0  and  projectiles_left == 0:
		timer_cooldown = current_stats[StatsManager.COOLDOWN]
		projectiles_left = current_stats[StatsManager.AMOUNT]-1
