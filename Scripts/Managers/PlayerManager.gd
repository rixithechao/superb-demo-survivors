extends Node

var hp = 100
var hp_max = 100
var data = load("res://Data Objects/Playables/Playable_Demo.tres")
var weapons = []
var passives = []
var equipment_stats = {}

var mercy_seconds : float = 0

var current_exp = 0
var exp_needed = 5
var level = 1

var instance


signal get_exp



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

	MenuManager.level_up()


func give_equipment(eqpData, type_array):
	type_array[type_array.size()] = eqpData
	equipment_stats[eqpData] = {level: 1}

func give_passive(eqpData):
	give_equipment(eqpData, passives)

func give_weapon(eqpData):
	give_equipment(eqpData, weapons)
	
	var tbl = equipment_stats[eqpData]
	tbl.timer_projectiles = 0
	tbl.timer_cooldown = 0
	tbl.projectiles = eqpData.amount
	tbl.scene = load(eqpData.projectile)



func give_exp(amount):
	current_exp += amount

	if  current_exp >= exp_needed and TimeManager.time_rate > 0:
		current_exp -= exp_needed
		level_up()
	
	emit_signal("get_exp")



func update_weapon(wpnData, delta):
	var tbl = equipment_stats[wpnData]
	
	tbl.timer_projectiles = max(0, tbl.timer_projectiles - delta)
	tbl.timer_cooldown = max(0, tbl.timer_cooldown - delta)
	
	if tbl.timer_projectiles <= 0  and  tbl.projectiles > 0:
		tbl.projectiles -= 1
		tbl.timer_projectiles = wpnData.projectile_interval
		var spawned = tbl.scene.instance()
		MapManager.instance.add_child(spawned)

	if  tbl.timer_cooldown <= 0  and  tbl.projectiles == 0:
		tbl.timer_cooldown = wpnData.cooldown
		tbl.projectiles = wpnData.amount



func reset_player():
	weapons = []
	passives = []
	equipment_stats = {}#data.starting_weapon: 1}
	give_weapon(data.starting_weapon)
	hp_max = data.max_hp
	hp = hp_max
	mercy_seconds = 0
	current_exp = 0
	exp_needed = 5
	level = 1


func _ready():
	reset_player()
	pass
	
func _process(delta):
	
	if TimeManager.time_rate > 0:
		for w in weapons:
			update_weapon(w, delta*TimeManager.time_rate)
