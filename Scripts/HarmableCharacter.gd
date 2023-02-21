extends Character
class_name HarmableCharacter


export var death_vfx : PackedScene

var _max_hp: float = 9999
var damage_taken: float = 0
var hitbox_delays = {}

var status_timers = {
	"freeze": 0.0,
	"knockback": 0.0
}
var knockback_dir: Vector2

var is_dying: bool = false
var world_origin_fix_timer : float = 0.1
var world_origin_fix_timer_over = false

var _drop_table : Resource


signal take_knockback
signal take_freeze
signal take_hit
signal take_damage


func on_hit():
	pass



func death_effects():
	$DeathAnimation.play("Death")
	pass

func harm_effects(calculated_damage, is_crit = false):
	$Graphic.flash(Color.white, 0.5)

	var damage_number = VFXManager.spawn(load("res://Prefabs/VFX/Prefab_VFX_DamageNumber.tscn"), position)
	damage_number.value = calculated_damage
	damage_number.is_crit = is_crit



func die(prevent_drops : bool = false):
	death_effects()
	if  death_vfx != null:
		VFXManager.spawn(death_vfx, position)
	is_dying = true
	
	# Spawn from the drop table
	if  _drop_table != null  and  not prevent_drops:
		var chosen_drop = _drop_table.get_drop()
		if chosen_drop != null:
			StageManager.spawn_pickup(chosen_drop, self.position)


func knock_back(force, duration):
	pass

func freeze(duration):
	pass


func damage(amount, is_crit):
	if  is_dying:
		return

	var calculated = amount

	var signal_data = {"cancelled":false, "amount":amount}
	emit_signal("take_damage", signal_data)
	HarmableManager.emit_signal("take_damage", signal_data)

	if  not signal_data.cancelled:
		damage_taken += signal_data.amount

	harm_effects(signal_data.amount, is_crit)


	# Die if damage reaches max HP
	if damage_taken >= _max_hp:
		die()


func apply_ailments(stats_table):
	pass


func hit_by_projectile(projectile):

	if  is_dying  or  world_origin_fix_timer > 0:
		return
	
	var weapon_data = projectile.weapon_data

	if  not hitbox_delays.has(weapon_data):

		hitbox_delays[weapon_data] = weapon_data.get_stat_current(StatsManager.HIT_INTERVAL)

		var signal_data = {"cancelled":false, "weapon_data":weapon_data, "target": self}
		emit_signal("take_hit", signal_data)
		HarmableManager.emit_signal("take_hit", signal_data)

		if  not signal_data.cancelled:

			# Check for crits
			var effect_chance = weapon_data.get_stat_current(StatsManager.EFFECT_CHANCE)
			var player_luck = PlayerManager.get_stat(StatsManager.LUCK)
			var critical_hit = randf() <= (effect_chance * player_luck)

			var total_stats = PlayerManager.get_current_stats(weapon_data)

			var signal_data2 = {"projectile": projectile, "target": self, "stats": total_stats}
			
			if  critical_hit:
				if  total_stats.has(StatsManager.CRIT):
					total_stats[StatsManager.DAMAGE] *= total_stats[StatsManager.CRIT]

				EquipmentManager.emit_signal("on_critical_hit", signal_data2)

			#print("Enemy hit by ", weapon_data.name, "\nWeapon DMG = ", weapon_dmg, ", Player STR = ", player_str, ", Player DMG = ", player_dmg, "\nBase stats = ", weapon_data._stats.values, "\nResulting stats = ", weapon_data.apply_stats({}))

			projectile.enemies_pierced += 1

			var total_damage = total_stats[StatsManager.DAMAGE]

			on_hit()
			apply_ailments(signal_data2.stats)
			damage(total_damage, critical_hit)


func extra_collision_init():
	pass



func _process(delta):

	if  Engine.editor_hint:
		return

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

	# process status
	for k in status_timers:
		status_timers[k] = max(0, status_timers[k] - delta * TimeManager.time_rate)


func _physics_process(delta):

	if Engine.editor_hint or TimeManager.is_paused or is_dying:
		return

	world_origin_fix_timer = max(0, world_origin_fix_timer - delta*TimeManager.time_rate)
	
	if  world_origin_fix_timer <= 0  and  not world_origin_fix_timer_over:
		world_origin_fix_timer_over = true
		$Collision.disabled = false
		extra_collision_init()
