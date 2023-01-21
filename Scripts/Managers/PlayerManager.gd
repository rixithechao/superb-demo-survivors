extends Node

var dead = false
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


signal get_exp
signal give_equipment


func change_hp(amount):
	var stats = get_current_stats()
	hp = clamp(hp+amount, 0, stats[StatsManager.MAX_HP])

	# Death
	if hp == 0 and not dead:
		dead = true
		WorldManager.instance.start_sequence("Sequence_Die")
		pass


func take_damage(amount):
	change_hp(-amount)


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



func roll_equipment(count: int = 1, use_only_obtained = false):
	var all_equipment = []
	
	# Pool of weapons and passives depends on whether the player has slots available
	if  weapons.size() < WEAPON_SLOTS and not use_only_obtained:
		all_equipment.append_array(EquipmentManager.all_weapons)
	else:
		all_equipment.append_array(weapons)
		
	if  passives.size() < PASSIVE_SLOTS and not use_only_obtained:
		all_equipment.append_array(EquipmentManager.all_passives)
	else:
		all_equipment.append_array(passives)
	
	var possible_count = min(count, all_equipment.size())

	
	# Remove equipment already at max level
	for eqp in all_equipment:
		#print(eqp, ", all=", all_equipment, ", stats=", equipment_levels)
		if  equipment_levels.has(eqp) and equipment_levels[eqp] == eqp.max_level:
			all_equipment.erase(eqp)


	# Add pickups if there's no equipment to give
	if all_equipment.size() == 0:
		all_equipment.append(load("res://Data Objects/Equipment/LevelUpPickupData_Coin.tres"))
		all_equipment.append(load("res://Data Objects/Equipment/LevelUpPickupData_Radish.tres"))
		possible_count = 2

	
	# Pick the amount needed (or possible)
	var selected = []
	var eqp

	while selected.size() < possible_count:
		eqp = all_equipment[randi() % all_equipment.size()]
		if selected.has(eqp):
			all_equipment.erase(eqp)
		else:
			selected.append(eqp)
	
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



func give_equipment(eqpData, type_array = null):
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
			tbl.projectiles = weapon_stats[StatsManager.AMOUNT]

			#print(eqpData, ", projScene=", eqpData.projectile, ", tbl=", tbl)
			equipment_timers[eqpData] = tbl
		
	else:
		equipment_levels[eqpData] += 1
	
	emit_signal("give_equipment", eqpData.equipment_type, type_array)
	
	return is_new

func give_passive(eqpData):
	give_equipment(eqpData, passives)
	print("Passive\n")

func give_weapon(eqpData):
	give_equipment(eqpData, weapons)
	print("Weapon\n")



func check_for_level_up():
	if  current_exp >= exp_needed and not TimeManager.is_paused:
		current_exp -= exp_needed
		level_up()


func give_exp(amount):
	current_exp += amount
	check_for_level_up()
	
	emit_signal("get_exp")


func give_coins(amount):
	coins += amount



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
		ProjectileManager.spawn(wpnData)

	if  tbl.timer_cooldown <= 0  and  tbl.projectiles == 0:
		tbl.timer_cooldown = wpnData.get_stat_current(StatsManager.COOLDOWN)
		tbl.projectiles = wpnData.get_stat_current(StatsManager.AMOUNT)-1



func reset_player():
	print("RESETTING PLAYER: ", data, "\n")
	
	weapons.clear()
	passives.clear()
	equipment_levels.clear()
	give_weapon(data.starting_weapon)
	hp = data.stats.values[StatsManager.MAX_HP]
	mercy_seconds = 0
	current_exp = 0
	exp_needed = 5
	level = 1


func _ready():
	pass

	
func _process(delta):
	
	if TimeManager.is_paused  or  dead:
		return

	mercy_seconds = max(0, mercy_seconds-delta)
	
	for w in weapons:
		update_weapon(w, delta*TimeManager.time_rate)
