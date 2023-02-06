extends Character
class_name HarmableCharacter

var _max_hp: float = 9999
var damage_taken: float = 0
var hitbox_delays = {}

var freeze_timer: float = 0

var is_dying: bool = false
var world_origin_fix_timer : float = 0.1
var world_origin_fix_timer_over = false

var _drop_table : Resource


func death_effects():
	$Graphic.fade(0, 0.25)
	pass

func harm_effects(calculated_damage):
	$Graphic.flash(Color.white, 0.5)

	var damage_number = VFXManager.spawn(load("res://Prefabs/VFX/Prefab_VFX_DamageNumber.tscn"), position)
	damage_number.value = calculated_damage



func die():
	death_effects()
	is_dying = true
	
	# Spawn from the drop table
	if  _drop_table != null  and  _drop_table.drops.size() > 0:
		var all_drops = []
		for drop in _drop_table.drops:
			for i in drop.weight:
				all_drops.append(drop)
		var chosen_drop = all_drops[randi() % all_drops.size()]
		if chosen_drop.pickup != null:
			StageManager.spawn_pickup(chosen_drop.pickup, self.position)



func damage(amount):
	if  is_dying:
		return

	var calculated = amount
	damage_taken += calculated

	harm_effects(calculated)



	# Die if damage reaches max HP
	if damage_taken >= _max_hp:
		die()

func hit_by_projectile(projectile):
	if  is_dying  or  world_origin_fix_timer > 0:
		return
	
	var weapon_data = projectile.weapon_data
	
	if  not hitbox_delays.has(weapon_data):
		
		hitbox_delays[weapon_data] = weapon_data.get_stat_current(StatsManager.HIT_INTERVAL)
		
		var weapon_dmg = weapon_data.get_stat_current(StatsManager.DAMAGE)
		var player_dmg = PlayerManager.get_stat(StatsManager.DAMAGE)
		#print("Enemy hit by ", weapon_data.name, "\nWeapon DMG = ", weapon_dmg, ", Player STR = ", player_str, ", Player DMG = ", player_dmg, "\nBase stats = ", weapon_data._stats.values, "\nResulting stats = ", weapon_data.apply_stats({}))
		
		damage(weapon_dmg * player_dmg)
		
		projectile.enemies_pierced += 1
	pass

func extra_collision_init():
	pass



func _process(delta):

	# process jumping/falling
	._process(delta)

	# process hitbox delays
	var clear_delays = false
	for k in hitbox_delays:
		hitbox_delays[k] -= TimeManager.time_rate*delta
		if hitbox_delays[k] <= 0:
			clear_delays = true
			break
	
	if clear_delays:
		hitbox_delays.clear()
	


func _physics_process(delta):

	if Engine.editor_hint or TimeManager.is_paused or is_dying:
		return

	world_origin_fix_timer = max(0, world_origin_fix_timer - delta*TimeManager.time_rate)
	
	if  world_origin_fix_timer <= 0  and  not world_origin_fix_timer_over:
		world_origin_fix_timer_over = true
		$Collision.disabled = false
		extra_collision_init()
