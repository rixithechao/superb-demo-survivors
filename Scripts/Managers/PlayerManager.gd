extends Node

var show_character_select = true
var show_serac = false

var dead = false
var deaths = 0
var revives = 0

var hp = 100
var data = load("res://Data Objects/Playables/Playable_Demo.tres")
var equipment = {
	"weapons": [],
	"passives": [],
	"boosts": []
}
var equipment_levels = {}
var equipment_nodes = {}

var mercy_seconds : float = 0
var recovery_timer : float = 1

var current_exp = 0
var exp_needed = 2
var level : int = 1
var coins : int = 0

var instance
var enemy_collision_area



const EQUIP_SLOTS = 4
const REVIVE_COST_LEVEL_MULT = 5
const REVIVE_COST_LEVEL_POWER = 0.01
const REVIVE_COST_DEATH_MULT = 0.45
const OBTAINED_BIAS_CHANCE = 0.6


signal modify_stats
signal modify_coins
signal modify_exp

signal change_coins
signal change_exp
signal update_exp_bar
signal change_equipment
signal take_hit
signal take_damage

signal revive_check



func reset_equipment():
	for  equip_group in equipment:
		equipment[equip_group].clear()
		print ("CLEARED PLAYER EQUIPMENT ", equip_group)
	equipment_levels.clear()
	equipment_nodes.clear()




func set_character(new_data):
	data = new_data
	reset_equipment()

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
	var signal_data = {"cancelled":false, "damage_dealt":amount}
	emit_signal("take_damage", signal_data)

	if  not signal_data.cancelled:
		change_hp(-signal_data.damage_dealt/get_stat(StatsManager.DEFENSE))

func heal(amount):
	change_hp(amount)


func hit_by_enemy(enemyData):
	#print("Player was hit by ", enemyData.name)
	if mercy_seconds <= 0 and not dead:

		var signal_data = {"cancelled":false, "enemy_data":enemyData}
		emit_signal("take_hit", signal_data)

		if  not signal_data.cancelled:
			take_damage(enemyData.stats.values[StatsManager.DAMAGE])
			mercy_seconds = 0.75
			instance.damage_effects()



func get_base_stats():
	return data.stats.values.duplicate()


func get_current_stats(weaponData = null):
	var modified = get_base_stats()

	#print("GET STATS:\ninitial=", modified)
	
	for boost in equipment.boosts:
		boost.apply_stats(modified)
		pass
		
	for passive in equipment.passives:
		passive.apply_stats(modified)
		pass

	emit_signal("modify_stats", modified)

	if  weaponData != null:
		modified = weaponData.apply_stats(modified)

	#print("PLAYER MANAGER: ", signal_data.stats, "\n\n")

	return modified


func has_stat(stat, weaponData=null):
	var current_stats = get_current_stats(weaponData)
	
	return current_stats.has(stat)

func get_stat(stat, weaponData=null):
	var current_stats = get_current_stats(weaponData)
	
	if current_stats.has(stat):
		return current_stats[stat]
	else:
		return stat.base_value




func roll_equipment(count: int = 1, use_only_obtained = false, obtained_bias = false, unbiased_option = false, offer_recovery = true):
	var valid_equipment = []
	var valid_owned = []
	valid_owned.append_array(equipment.weapons)
	valid_owned.append_array(equipment.passives)

	
	# Main pool of each equipment type depends on whether the player has slots available
	if  equipment.weapons.size() < EQUIP_SLOTS  and  not use_only_obtained:
		valid_equipment.append_array(EquipmentManager.all_weapons)
	else:
		valid_equipment.append_array(equipment.weapons)

	if  equipment.passives.size() < EQUIP_SLOTS  and  not use_only_obtained:
		valid_equipment.append_array(EquipmentManager.all_passives)
	else:
		valid_equipment.append_array(equipment.passives)
		
	# if  equipment.boosts.size() < EQUIP_SLOTS  and  not use_only_obtained:
	if  not use_only_obtained:
		valid_equipment.append_array(EquipmentManager.all_boosts)
	else:
		valid_equipment.append_array(equipment.boosts)


	# Remove equipment already at max level
	var idx = 0
	while idx < valid_equipment.size():
		var eqp = valid_equipment[idx]
		if  equipment_levels.has(eqp) and equipment_levels[eqp] >= eqp.max_level:
			valid_equipment.erase(eqp)
			valid_owned.erase(eqp)
		else:
			idx+=1
		
	
	#for eqp in valid_equipment:
		#print(eqp, ", all=", valid_equipment, ", stats=", equipment_levels)
	#	if  equipment_levels.has(eqp) and equipment_levels[eqp] >= eqp.max_level:
	#		valid_equipment.erase(eqp)
	#		valid_owned.erase(eqp)
	
	var maxed_weapons = true
	for eqp in equipment.weapons:
		if not equipment_levels.has(eqp) or equipment_levels[eqp] < eqp.max_level:
			maxed_weapons = false
			break
			
	var maxed_passives = true
	for eqp in equipment.passives:
		if not equipment_levels.has(eqp) or equipment_levels[eqp] < eqp.max_level:
			maxed_passives = false
			break
			
	# Add pickups for each individual type that's full (they spawn once you have full maxed weapons or passives)
	if (equipment.weapons.size() >= EQUIP_SLOTS and maxed_weapons)  or  (equipment.passives.size() >= EQUIP_SLOTS and maxed_passives):
		valid_equipment.append(load("res://Data Objects/Equipment/LevelUpPickupData_Coin.tres"))
		if  offer_recovery:
			valid_equipment.append(load("res://Data Objects/Equipment/LevelUpPickupData_Radish.tres"))
			
	# Add pickups if there's no equipment to give
	else:
		if valid_equipment.size() == 0:
			valid_equipment.append(load("res://Data Objects/Equipment/LevelUpPickupData_Coin.tres"))
			if  offer_recovery:
				valid_equipment.append(load("res://Data Objects/Equipment/LevelUpPickupData_Radish.tres"))

	var possible_count = min(count, valid_equipment.size())

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
		if  (obtained_bias  and  randf() < OBTAINED_BIAS_CHANCE  and  weighted_owned.size() > 0  and  not (unbiased_option and selected.size() == possible_count-1)):
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
	# No we're not because that's way too slow
	# We're using a modified formula
	var next_level = level+1
	
	match(next_level):
		20:
			exp_needed = (next_level*5)-5+300
		40:
			exp_needed = (next_level*6)-6+600
		_:
			if next_level < 20: 
				exp_needed = (next_level*5)-5
				
			elif next_level < 40:
				exp_needed = (next_level*6)-6
			
			else:
				exp_needed = (next_level*8)-8

	MenuManager.open("levelup")



func give_equipment(eqpData, type_array = null, should_emit_signal = true):
	print("GIVING EQUIPMENT: ", eqpData.name, ", data=", eqpData, "\n")
	
	if type_array == null:
		match eqpData.equipment_type:
			EquipmentData.EquipmentType.WEAPON:
				type_array = equipment.weapons
			EquipmentData.EquipmentType.PASSIVE:
				type_array = equipment.passives
			EquipmentData.EquipmentType.BOOST:
				type_array = equipment.boosts

	var is_new = (not equipment_levels.has(eqpData))
	
	#print("DOES THE EQUIPMENT HAVE A LEVELS ENTRY?\nfull stats table=", equipment_levels, "\n", equipment_levels.has(eqpData), ", ", is_new)
	
	if  is_new:
		type_array.append(eqpData)
		var tbl = {}
		equipment_levels[eqpData] = 1

		if  eqpData.prefab != null  and  instance != null  and  is_instance_valid(instance):
			equipment_nodes[eqpData] = EquipmentManager.add(eqpData)

	else:
		equipment_levels[eqpData] += 1

	if  should_emit_signal:
		print("EQUIPMENT CHANGED SIGNAL")
		emit_signal("change_equipment", eqpData.equipment_type, type_array)

	return is_new

func give_passive(eqpData, should_emit_signal = true):
	give_equipment(eqpData, equipment.passives, should_emit_signal)
	print("Passive\n")

func give_weapon(eqpData, should_emit_signal = true):
	give_equipment(eqpData, equipment.weapons, should_emit_signal)
	print("Weapon\n")

func give_boost(eqpData, should_emit_signal = true):
	give_equipment(eqpData, equipment.boosts, should_emit_signal)
	print("Stat boost\n")



func check_for_level_up():
	emit_signal("update_exp_bar")
	if  current_exp >= exp_needed and not TimeManager.is_paused:
		current_exp -= exp_needed
		level_up()



func set_exp(amount):
	current_exp = amount
	check_for_level_up()

func give_exp(amount):
	var signal_data = {"cancelled":false, "amount":amount}
	emit_signal("modify_exp", signal_data)

	if  not signal_data.cancelled:
		set_exp(current_exp + signal_data.amount*get_stat(StatsManager.XP_MULT))



func set_coins(amount):
	coins = amount
	emit_signal("change_coins")

func give_coins(amount):
	var signal_data = {"cancelled":false, "amount":amount}
	emit_signal("modify_coins", signal_data)

	if  not signal_data.cancelled:
		set_coins(coins + ceil(signal_data.amount*get_stat(StatsManager.MONEY_MULT)))

func remove_coins(amount):
	set_coins(max(0, coins - amount))



func get_revive_cost():
	var base_cost = floor(pow(((level*REVIVE_COST_LEVEL_MULT) + 2), REVIVE_COST_DEATH_MULT*sqrt(deaths+1) + REVIVE_COST_LEVEL_POWER*level))

	return base_cost

func revive():
	mercy_seconds = 3
	var curr_stats = get_current_stats()
	set_hp(curr_stats[StatsManager.MAX_HP])
	instance.start_sequence("Sequence_Spawn")
	WorldManager.instance.start_sequence("Sequence_Revive")
	MusicManager.resume()
	dead = false
	revives += 1
	pass




func reset_player():
	print("RESETTING PLAYER: ", data, "\n")
	
	dead = false
	deaths = 0
	revives = 0

	reset_equipment()

	hp = data.stats.values[StatsManager.MAX_HP]
	mercy_seconds = 0
	set_coins(0)
	level = 1
	set_exp(0)
	exp_needed = 2


func unload_player():
	instance.remove_child(CameraManager.instance)
	WorldManager.world_objects_node.add_child(CameraManager.instance)
	instance.queue_free()
	instance = null


func spawn():
	instance = data.prefab.instance()
	WorldManager.world_objects_node.add_child(instance)
	give_weapon(data.starting_weapon)


func _ready():
	StageManager.connect("stage_exited", self, "_on_stage_exit")
	pass

	
func _process(delta):
	
	if  TimeManager.is_paused  or  dead:
		return

	mercy_seconds = max(0, mercy_seconds-delta*TimeManager.time_rate)
	
	recovery_timer -= delta*TimeManager.time_rate
	while recovery_timer <= 0:
		recovery_timer += 1
		heal(get_stat(StatsManager.RECOVERY))




func _on_stage_exit():
	instance = null
