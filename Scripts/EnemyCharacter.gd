tool
extends HarmableCharacter
class_name EnemyCharacter


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
export var custom_facing : bool = false
export var collides_with_other_enemies : bool = true
var move_mode = EnemyMoveMode.FOLLOW
var move_speed : Vector2 = Vector2(1,0)
var other_speed_mult: float = 1

var current_move_dir : Vector2

var spawn_type : int = 1
var treasure : Resource
var is_final_boss : bool = false

var despawn_timer: float = 3




const DESPAWN_TIMEOUT = 3
const BASE_MOVE_SPEED = 40



func die(prevent_drops : bool = false):
	print("Enemy died\n")

	# Bosses spawn a boss item (chest, anvil, etc)
	if  spawn_type == EnemySpawnType.BOSS:
		if treasure != null:
			StageManager.spawn_pickup(treasure, self.position)
		
		if  is_final_boss:
			EnemyManager.clear_all_enemies()
			MusicManager.stop()
			StageManager.clear_stage()
		pass

	_drop_table = data.drop_table
	
	if !prevent_drops: #todo: replace this with an actual test if the player killed them or not
		EnemyManager.add_kill()
	.die(prevent_drops)


func knock_back(force, duration):
	status_timers.knockback = duration
	knockback_dir = current_move_dir * force * (-1/data.get_stat(StatsManager.STURDINESS))

func freeze(duration):
	status_timers.freeze = duration/(1+data.get_stat(StatsManager.INERTIA))

func apply_ailments(stats_table):

	# knockback
	if  stats_table.has(StatsManager.KNOCKBACK):
		var weapon_knockback = stats_table[StatsManager.KNOCKBACK]
		knock_back(weapon_knockback, 0.12)

	# freeze
	if  stats_table.has(StatsManager.FREEZE):
		var weapon_freeze = stats_table[StatsManager.FREEZE]
		freeze(weapon_freeze)



func extra_collision_init():
	set_collision_mask_bit ( 3, collides_with_other_enemies )
	set_collision_layer_bit ( 3, collides_with_other_enemies )
	set_collision_layer_bit ( 7, not collides_with_other_enemies )

func get_z_top():
	return height + data.height



func custom_movement(delta : float = 0.0):
	return Vector2.ZERO


func apply_movement(delta):
	var direction = move_speed

	# Apply knockback
	if  status_timers.knockback > 0:
		direction = knockback_dir

	# Apply regular movement patterns
	else:

		match move_mode:
			EnemyMoveMode.FOLLOW:
				var player_pos = PlayerManager.instance.position
				var dir_to_player = (player_pos-position).normalized()
				direction = dir_to_player
			
			EnemyMoveMode.CUSTOM:
				direction = custom_movement(delta)

		current_move_dir = direction


		if direction.x != 0  and  not custom_facing:
			$Graphic.mirror = ( sign(direction.x) == -1 )

	# warning-ignore:return_value_discarded
	move_and_slide(direction * BASE_MOVE_SPEED * other_speed_mult * data.get_stat(StatsManager.MOVEMENT) * TimeManager.time_rate, Vector2.UP)



func _ready():
	if  not Engine.editor_hint:
		_max_hp = data.get_stat(StatsManager.MAX_HP)


func _process(delta):
	
	if Engine.editor_hint  or  TimeManager.is_paused  or  is_dying:
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
	if  despawn_timer <= 0  and  not is_dying:
		#print("Enemy despawned offscreen\n")
		die(true)


	# Hit delays, status timers, vertical movement
	._process(delta)
	$Graphic.freeze_active = (status_timers.freeze > 0)


	# Process movement
	if not TimeManager.is_paused:

		if status_timers.freeze <= 0:
			apply_movement(delta)




func _physics_process(delta):

	._physics_process(delta)
	
	if  Engine.editor_hint  or  TimeManager.is_paused  or  is_dying:
		return


	if  PlayerManager.enemy_collision_area.overlaps_body(self)  and  CharacterManager.check_z_overlap(self, PlayerManager.instance):
		if world_origin_fix_timer <= 0:
			PlayerManager.hit_by_enemy(data)
		else:
			#print("what the fuck is happening")
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
