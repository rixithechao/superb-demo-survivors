extends Node


enum ProjectileTargetType {
	PLAYER,
	ENEMY_RANDOM,
	ENEMY_NEAREST
}

enum ProjectileAimType {
	NONE,
	PLAYER_HORIZONTAL,
	PLAYER_VERTICAL,
	PLAYER_DIAGONAL,
	PLAYER_4DIR,
	PLAYER_8DIR,
	TO_PLAYER,
	TO_ENEMY_RANDOM,
	TO_ENEMY_NEAREST
}

export var weapon_data : Resource
export var relative_position = true
export var spawn_radius : float = 0
export(ProjectileTargetType) var target_type = ProjectileTargetType.PLAYER
export(ProjectileAimType) var aim_type = ProjectileAimType.PLAYER_HORIZONTAL
export var aim_spread : float = 0
export var speed : float = 1

var fire_speed : Vector2
var target_node



func custom_movement():
	pass




func _ready():
	
	# Spawn at the target
	match target_type:
		ProjectileTargetType.PLAYER:
			target_node = PlayerManager.instance

		ProjectileTargetType.ENEMY_RANDOM:
			target_node = EnemyManager.get_random()

		ProjectileTargetType.ENEMY_NEAREST:
			target_node = EnemyManager.get_nearest()

	if not relative_position:
		self.position = target_node.position


	# Fire
	var fire_direction = Vector2.ZERO
	var enemy_node
	
	match aim_type:
		ProjectileAimType.PLAYER_HORIZONTAL:
			fire_direction = Vector2(PlayerManager.instance.last_facing.x, 0)
		
		ProjectileAimType.PLAYER_VERTICAL:
			fire_direction = Vector2(0, PlayerManager.instance.last_facing.y)
		
		ProjectileAimType.PLAYER_DIAGONAL:
			fire_direction = PlayerManager.instance.last_facing
		
		ProjectileAimType.TO_ENEMY_NEAREST:
			enemy_node = EnemyManager.get_nearest()
		
		ProjectileAimType.TO_ENEMY_RANDOM:
			enemy_node = EnemyManager.get_random()

	if enemy_node != null:
		fire_direction = enemy_node.position - self.position

	fire_speed = fire_direction.normalized() * speed #*PlayerManager.get_weapon_speed()

	
func _process(delta):
	if  relative_position and target_node != null:
		self.position = target_node.position
	
	$LocalPos.move_and_slide(fire_speed, Vector2.UP)
