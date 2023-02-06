extends Node

var show_character_select = true
var show_serac = false

var dead = false
var deaths = 0
var revives = 0

var hp = 100
var data = load("res://Data Objects/Playables/Playable_Demo.tres")
var weapons = []
var passives = []

var equipment_levels = {}
var equipment_timers = {}

var mercy_seconds : float = 0

var current_exp = 0
var exp_needed = 5
var level : int = 1
var coins : int = 0

var instance
var enemy_collision_area



const WEAPON_SLOTS = 7
const PASSIVE_SLOTS = 7
const REVIVE_COST_LEVEL_MULT = 0.25
const REVIVE_COST_DEATH_MULT = 5
const OBTAINED_BIAS_CHANCE = 0.6


signal change_coins
signal change_exp
signal update_exp_bar
signal change_equipment



func set_character(new_data):
	data = new_data
	weapons.clear()
	passives.clear()
	equipment_levels.clear()
	equipment_timers.clear()
	give_weapon(data.starting_weapon)
	hp = data.stats.values[StatsManager.MAX_HP]




func die():
	deaths += 1
	dead = true
	MusicManager.pause()
	WorldManager.instance.start_sequence("Sequence_Die")



func set_hp(amount):
	var stats = get_current_stats()
	hp = clamp(amount, 0, stats[StatsManager.MAX_HP])

	# Death
	if hp == 0 and not dead:
		die()
		pass

func change_hp(amount):
	set_hp(hp+amount)

func take_damage(amount):
	change_hp(-amount)

func heal(amount):
	change_hp(amount)


func hit_by_enemy(enemyData):
	#print("Player was hit by ", enemyData.name)
	if mercy_seconds <= 0 and not dead:
		take_damage(enemyData.stats.values[StatsManager.DAMAGE])
		mercy_seconds = 0.75
		instance.damage_effects()



func get_base_stats():
	return data.stats.values.duplicate()


func get_current_stats():
	var modified = get_base_stats()

	#print("GET STATS:\ninitial=", modified)
	
	for passive in passives:
		passive.apply_stats(modified)
		pass

	#print("current=", modified, "\n")

	return modified


func get_stat(stat, weaponData=null):
	var current_stats = get_current_stats()
	if weaponData != null:
		current_stats = weaponData.apply_stats(current_stats)
	
	if current_stats.has(stat):
		return current_stats[stat]
	else:
		return stat.base_value



func roll_equipment(count: int = 1, use_only_obtained = false, obtained_bias = false, offer_recovery = true):
	var valid_equipment = []
	var valid_owned = []
	valid_owned.append_array(weapons)
	valid_owned.append_array(passives)

	
	# Main pool of weapons and passives depends on whether the player has slots available
	if  weapons.size() < WEAPON_SLOTS  and  not use_only_obtained:
		valid_equipment.append_array(EquipmentManager.all_weapons)
	else:
		valid_equipment.append_array(weapons)
		
	if  passives.size() < PASSIVE_SLOTS  and  not use_only_obtained:
		valid_equipment.append_array(EquipmentManager.all_passives)
	else:
		valid_equipment.append_array(passives)


	# Remove equipment already at max level
	for eqp in valid_equipment:
		#print(eqp, ", all=", valid_equipment, ", stats=", equipment_levels)
		if  equipment_levels.has(eqp) and equipment_levels[eqp] == eqp.max_level:
			valid_equipment.erase(eqp)
			valid_owned.erase(eqp)

	var possible_count = min(count, valid_equipment.size())


	# Add pickups if there's no equipment to give
	if valid_equipment.size() == 0:
		valid_equipment.append(load("res://Data Objects/Equipment/LevelUpPickupData_Coin.tres"))
		possible_count = 1

		if  offer_recovery:
			valid_equipment.append(load("res://Data Objects/Equipment/LevelUpPickupData_Radish.tres"))
			possible_count = 2


	# Derive weighted equipment table
	var weighted_equipment = []
	for eqp in valid_equipment:
		for i in eqp.rarity:
			weighted_equipment.append(eqp)

	var weighted_owned = []
	for eqp in valid_owned:
		for i in eqp.rarity:
			weighted_owned.append(eqp)


	# Pick the amount needed (or possible)
	var selected = []
	var eqp

	while selected.size() < possible_count:

		# Chance to select an owned piece of equipment
		if  (obtained_bias  and  randf() < OBTAINED_BIAS_CHANCE  and  weighted_owned.size() > 0):
			eqp = weighted_owned[randi() % weighted_owned.size()]
		else:
			eqp = weighted_equipment[randi() % weighted_equipment.size()]
		
		selected.append(eqp)
		
		while weighted_equipment.has(eqp):
			weighted_equipment.erase(eqp)
		while weighted_owned.has(eqp):
			weighted_owned.erase(eqp)
	
	return {"selected": selected, "reduced": (possible_count < count)}




func level_up():
	
	# Increment level
	level += 1
	
	# Determine the XP needed for the next level
	# We're using the exact formula from VS
	var next_level = level+1
	
	match(next_level):
		20:
			exp_needed = (next_level*10)-5+600
		40:
			exp_needed = (next_level*13)-6+2400
		_:
			if next_level < 20: 
				exp_needed = (next_level*10)-5
				
			elif next_level < 40:
				exp_needed = (next_level*13)-6
			
			else:
				exp_needed = (next_level*16)-8

	MenuManager.open("levelup")



func give_equipment(eqpData, type_array = null, should_emit_signal = true):
	print("GIVING EQUIPMENT: ", eqpData.name, ", data=", eqpData, "\n")
	
	if type_array == null:
		match eqpData.equipment_type:
			EquipmentData.EquipmentType.PASSIVE:
				type_array = passives
			EquipmentData.EquipmentType.WEAPON:
				type_array = weapons

	var is_new = (not equipment_levels.has(eqpData))
	
	#print("DOES THE EQUIPMENT HAVE A LEVELS ENTRY?\nfull stats table=", equipment_levels, "\n", equipment_levels.has(eqpData), ", ", is_new)
	
	if  is_new:
		type_array.append(eqpData)
		var tbl = {}
		equipment_levels[eqpData] = 1

		if eqpData.equipment_type == EquipmentData.EquipmentType.WEAPON:
			var weapon_stats = eqpData.apply_stats(get_current_stats())
			
			tbl.timer_projectiles = 0
			tbl.timer_cooldown = weapon_stats[StatsManager.COOLDOWN]
			tbl.projectiles = weapon_stats[StatsManager.AMOUNT]-1

			#print(eqpData, ", projScene=", eqpData.projectile, ", tbl=", tbl)
			equipment_timers[eqpData] = tbl
		
	else:
		equipment_levels[eqpData] += 1
	
	if  should_emit_signal:
		emit_signal("change_equipment", eqpData.equipment_type, type_array)
	
	return is_new

func give_passive(eqpData, should_emit_signal = true):
	give_equipment(eqpData, passives, should_emit_signal)
	print("Passive\n")

func give_weapon(eqpData, should_emit_signal = true):
	give_equipment(eqpData, weapons, should_emit_signal)
	print("Weapon\n")



func check_for_level_up():
	emit_signal("update_exp_bar")
	if  current_exp >= exp_needed and not TimeManager.is_paused:
		current_exp -= exp_needed
		level_up()



func set_exp(amount):
	current_exp = amount
	check_for_level_up()

func give_exp(amount):
	set_exp(current_exp + amount)



func set_coins(amount):
	coins = amount
	emit_signal("change_coins")

func give_coins(amount):
	set_coins(coins + amount)

func remove_coins(amount):
	set_coins(max(0, coins - amount))



func get_revive_cost():
	return floor(pow(REVIVE_COST_DEATH_MULT*(deaths+1), 1 + REVIVE_COST_LEVEL_MULT*level))

func revive():
	mercy_seconds = 3
	var curr_stats = get_current_stats()
	set_hp(curr_stats[StatsManager.MAX_HP])
	instance.start_sequence("Sequence_Spawn")
	WorldManager.instance.start_sequence("Sequence_Revive")
	dead = false
	revives += 1
	pass



func update_weapon(wpnData, delta):
	var tbl = equipment_timers[wpnData]
	
	if not tbl.has("timer_projectiles"):
		#print("WEAPON WITHOUT TIMER: ", wpnData, ", ", tbl)
		return
	
	#print("UPDATING WEAPON: ", wpnData.name, "\n")
	
	tbl.timer_projectiles = max(0, tbl.timer_projectiles - delta)
	tbl.timer_cooldown = max(0, tbl.timer_cooldown - delta)
	
	var current_stats = wpnData.apply_stats(get_current_stats())
	#print ("FINAL WEAPON STATS: ", current_stats)
	
	if tbl.timer_projectiles <= 0  and  tbl.projectiles > 0:
		tbl.projectiles -= 1
		tbl.timer_projectiles = current_stats[StatsManager.SHOT_INTERVAL]
		ProjectileManager.spawn(wpnData, tbl.projectiles)

		#print("PROJECTILE FIRED: ", wpnData.name,"\n", tbl, "\n\n", wpnData.stats.apply_stats({}), "\n\n", current_stats, "\n")


	if  tbl.timer_cooldown <= 0  and  tbl.projectiles == 0:
		tbl.timer_cooldown = current_stats[StatsManager.COOLDOWN]
		tbl.projectiles = current_stats[StatsManager.AMOUNT]-1




func reset_player():
	print("RESETTING PLAYER: ", data, "\n")
	
	dead = false
	deaths = 0
	revives = 0
	weapons.clear()
	passives.clear()
	equipment_levels.clear()
	equipment_timers.clear()
	give_weapon(data.starting_weapon)
	hp = data.stats.values[StatsManager.MAX_HP]
	mercy_seconds = 0
	set_coins(0)
	level = 1
	set_exp(0)
	exp_needed = 5


func unload_player():
	instance.remove_child(CameraManager.instance)
	WorldManager.world_objects_node.add_child(CameraManager.instance)
	instance.queue_free()
	instance = null


func spawn():
	instance = data.prefab.instance()
	WorldManager.world_objects_node.add_child(instance)


func _ready():
	StageManager.connect("stage_exited", self, "_on_stage_exit")
	pass

	
func _process(delta):
	
	if TimeManager.is_paused  or  dead:
		return

	mercy_seconds = max(0, mercy_seconds-delta)
	
	for w in weapons:
		update_weapon(w, delta*TimeManager.time_rate)



func _on_stage_exit():
	instance = null
