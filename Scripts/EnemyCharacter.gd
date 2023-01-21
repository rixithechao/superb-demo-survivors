tool
extends Character


enum EnemyMoveMode {
	FOLLOW,
	LINE,
	WAVE,
	CUSTOM
}
enum EnemySpawnType {
	NORMAL,
	BOSS,
	EVENT
}


export var data : Resource
var move_mode = EnemyMoveMode.FOLLOW
var move_speed : Vector2 = Vector2(1,0)
var spawn_type : int = 1
var treasure : Resource

var damage: float = 0
var freeze_timer: float = 0
var despawn_timer: float = 3
var world_origin_fix_timer : float = 0.1
var world_origin_fix_timer_over = false
var collides_with_other_enemies : bool = true

var hitbox_delays = {}

var is_dying = false

const DESPAWN_TIMEOUT = 3


func die():
	is_dying = true

	$Graphic.fade(0, 0.25)
	print("Enemy died\n")
	
	# Bosses spawn a boss item (chest, anvil, etc)
	if spawn_type == EnemySpawnType.BOSS:
		if treasure != null:
			StageManager.spawn_pickup(treasure, self.position)
		pass
	
	# Also spawn from the drop table
	if data.drop_table != null and data.drop_table.drops.size() > 0:
		var all_drops = []
		for drop in data.drop_table.drops:
			for i in drop.weight:
				all_drops.append(drop)
		var chosen_drop = all_drops[randi() % all_drops.size()]
		if chosen_drop.pickup != null:
			StageManager.spawn_pickup(chosen_drop.pickup, self.position)


func damage(amount):
	if  is_dying:
		return

	var calculated = amount
	damage += calculated

	$Graphic.flash(Color.white, 0.5)
	var damage_number = VFXManager.spawn(load("res://Prefabs/VFX/Prefab_VFX_DamageNumber.tscn"), position)
	damage_number.value = calculated

	
	# Die if damage reaches max HP
	if damage >= data.get_stat(StatsManager.MAX_HP):
		die()



func hit_by_projectile(projectile):
	if  is_dying  or  world_origin_fix_timer > 0:
		return
	
	var weapon_data = projectile.weapon_data
	
	if  not hitbox_delays.has(weapon_data):
		
		hitbox_delays[weapon_data] = weapon_data.get_stat_current(StatsManager.HIT_INTERVAL)
		
		var weapon_dmg = weapon_data.get_stat_current(StatsManager.DAMAGE)
		var player_str = PlayerManager.get_stat(StatsManager.STRENGTH)
		var player_dmg = PlayerManager.get_stat(StatsManager.DAMAGE)
		#print("Enemy hit by ", weapon_data.name, "\nWeapon DMG = ", weapon_dmg, ", Player STR = ", player_str, ", Player DMG = ", player_dmg, "\nBase stats = ", weapon_data._stats.values, "\nResulting stats = ", weapon_data.apply_stats({}))
		
		damage(weapon_dmg * player_str)
		
		projectile.enemies_pierced += 1
	pass


func custom_movement():
	return Vector2.ZERO


func apply_movement():
	var direction = move_speed
	
	match move_mode:
		EnemyMoveMode.FOLLOW:
			var player_pos = PlayerManager.instance.position
			direction = (player_pos-position).normalized()
		
		EnemyMoveMode.CUSTOM:
			direction = custom_movement()
			
	
	if direction.x != 0:
		$Graphic/Sprite.set_flip_h( sign(direction.x) == -1 )
	
	move_and_slide(direction * 50 * data.get_stat(StatsManager.MOVEMENT) * TimeManager.time_rate, Vector2.UP)



func _process(delta):
	
	if Engine.editor_hint or TimeManager.is_paused or is_dying:
		return


	match spawn_type:

		# Bosses clamp to the spawn perimeter
		EnemySpawnType.BOSS:
			despawn_timer = DESPAWN_TIMEOUT

			var extents = CameraManager.spawn_shape.shape.extents
			var player_pos = PlayerManager.instance.position

			position.x = clamp(position.x, 
				player_pos.x - extents.x,
				player_pos.x + extents.x
			)
			position.y = clamp(position.y, 
				player_pos.y - extents.y,
				player_pos.y + extents.y
			)

		# Event enemies always count down to despawn 
		EnemySpawnType.EVENT:
			despawn_timer -= TimeManager.time_rate * delta
			pass

		# Regular enemies despawn outside a larger range
		_:
			if CameraManager.despawn_area.overlaps_body(self):
				despawn_timer = DESPAWN_TIMEOUT
			else:
				despawn_timer -= TimeManager.time_rate * delta
	
	
	# Despawn if time runs out
	if  despawn_timer <= 0:
		print("Enemy despawned offscreen\n")
		self.queue_free()


	# process hitbox delays
	var clear_delays = false
	for k in hitbox_delays:
		hitbox_delays[k] -= TimeManager.time_rate*delta
		if hitbox_delays[k] <= 0:
			clear_delays = true
			break
	
	if clear_delays:
		hitbox_delays.clear()
	
	
	# process movement
	if not TimeManager.is_paused:
		if freeze_timer <= 0:
			apply_movement()
		else:
			freeze_timer -= delta*TimeManager.time_Rate


	# Update depth sorting
	#update_z()

func _physics_process(delta):
	
	if Engine.editor_hint or TimeManager.is_paused or is_dying:
		return

	world_origin_fix_timer = max(0, world_origin_fix_timer - delta*TimeManager.time_rate)
	
	if  world_origin_fix_timer <= 0  and  not world_origin_fix_timer_over:
		world_origin_fix_timer_over = true
		$Collision.disabled = false
		set_collision_mask_bit ( 3, collides_with_other_enemies )
		set_collision_layer_bit ( 3, collides_with_other_enemies )
		set_collision_layer_bit ( 7, not collides_with_other_enemies )


	if  PlayerManager.enemy_collision_area.overlaps_body(self):
		if world_origin_fix_timer <= 0:
			PlayerManager.hit_by_enemy(data)
		else:
			#print("what the fuck is happening")
			pass
	


func _ready():
	pass


func _init():
	#for info in get_property_list():
		#print(info)
	pass



func _set(prop_name: String, val) -> bool:
	# Assume the property exists
	var retval: bool = true
	
	match prop_name:
		"Data":
			data = val
			property_list_changed_notify()
		
		"Movement/Mode":
			move_mode = val
			property_list_changed_notify()
		
		"Movement/Speed":
			move_speed = val
		
		"Spawning/Spawn Type":
			spawn_type = val
			property_list_changed_notify()
		
		"Spawning/Boss Treasure":
			treasure = val
		
		"Spawning/Despawn Timer":
			despawn_timer = val
		
		_:
			# If here, trying to set a property we are not manually dealing with.
			retval = false
	
	return retval

func _get(prop_name: String):
	var retval = null
	
	match prop_name:
		"Data":
			return data
		
		"Movement/Mode":
			return move_mode
		
		"Movement/Speed":
			return move_speed
		
		"Spawning/Spawn Type":
			return spawn_type
		
		"Spawning/Boss Treasure":
			return treasure
	
		"Spawning/Despawn Timer":
			return despawn_timer
	
	return retval

func _get_property_list():
	var list = []

	
	list.append({
		"name": "Movement/Mode",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "Follow,Line,Wave,Custom"
	})

	if (move_mode != EnemyMoveMode.FOLLOW and move_mode != EnemyMoveMode.CUSTOM):
		list.append({
			#"class_name": "Resource",
			"name": "Movement/Speed",
			"type": TYPE_VECTOR2,
			"tooltip": "..test",
			#"usage": PROPERTY_USAGE_STORAGE,
			#"hint": PROPERTY_HINT_RESOURCE_TYPE,
			#"string_hint": "Scene"
		})

	list.append({
		"name": "Spawning/Spawn Type",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "NORMAL,BOSS,EVENT"
	})

	if (spawn_type == EnemySpawnType.BOSS):
		list.append({
			#"class_name": "Resource",
			"name": "Spawning/Boss Treasure",
			"type": TYPE_OBJECT,
			#"usage": PROPERTY_USAGE_STORAGE,
			"hint": PROPERTY_HINT_RESOURCE_TYPE,
			#"string_hint": "Scene"
		})
		
	if (spawn_type == EnemySpawnType.EVENT):
		list.append({
			#"class_name": "Resource",
			"name": "Spawning/Despawn Timer",
			"type": TYPE_REAL,
			#"string_hint": "Scene"
		})

	return list




func _on_Tween_tween_completed(object, key):
	#print("TWEEN COMPLETED. obj=", object, ", key=", key)
	if  is_dying  and  key == ":modulate":
		#print("I can die now!")
		self.queue_free()
