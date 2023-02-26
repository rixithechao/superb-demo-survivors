tool
extends EnemyCharacter


enum BossState {
	AVOID,
	WARNING,
	CHARGE,
}

export var bullet : PackedScene

var boss_state = BossState.AVOID
var approach_speed : float = 0
var orbit_dir = -1
var charge_dir : Vector2

var warning_ref


const IDEAL_DIST = 300
const APPROACH_ACCEL = 2
const MAX_APPROACH_SPEED = 2
const CHARGE_SPEED = 15


func custom_movement(delta : float = 0.0):
	var dir

	var player_pos = PlayerManager.instance.position
	var to_player = player_pos-position
	var player_dist = to_player.length()
	var player_dir = to_player.normalized()


	# Behavior based on current state
	match boss_state:
		BossState.AVOID:
			var approach_sign = (-1 if player_dist > IDEAL_DIST else 1)
			var approach_add = APPROACH_ACCEL*delta*approach_sign

			approach_speed = clamp(approach_speed + approach_add, -MAX_APPROACH_SPEED, MAX_APPROACH_SPEED)

			dir = player_dir.rotated(deg2rad(60*orbit_dir*approach_sign)) * approach_speed

		BossState.WARNING:
			dir = Vector2.ZERO
			warning_ref.get_node("Telegraph/Direction").global_rotation = to_player.angle()

		BossState.CHARGE:
			dir = charge_dir * CHARGE_SPEED
			if  $ChargeTimer.time_left <= 0  and  player_dist > 500:
				finish_charge()

	# Face player except when charging
	if  boss_state != BossState.CHARGE:
		$Graphic.mirror = ( sign(player_dir.x) == -1 )

	return dir


func _ready():
	collides_with_other_enemies = false
	._ready()



func _on_AvoidTimer_timeout():
	if  is_dying:
		return

	warning_ref = $ChargeWarning
	boss_state = BossState.WARNING
	warning_ref.start()

func _on_ChargeWarning_on_spawn(node):
	if  is_dying:
		return

	boss_state = BossState.CHARGE
	$ChargeTimer.start()
	var player_pos = PlayerManager.instance.position
	charge_dir = (player_pos-position).normalized()

func finish_charge():
	if  is_dying:
		return

	$ShotTimer.start()
	boss_state = BossState.AVOID
	$AvoidTimer.start()
	orbit_dir = pow(-1, randi() % 2)
	
	var parnt = warning_ref.get_parent()
	parnt.remove_child(warning_ref)
	add_child(warning_ref)
	warning_ref.position = Vector2.ZERO



func shoot_bullet():
	if  is_dying:
		return

	var spawned = bullet.instance()
	spawned.global_position = $Graphic/AirOffset/CannonSprite.global_position
	spawned.height = ($Graphic/AirOffset/CannonSprite.global_position.y - global_position.y)/16
	WorldManager.add_object(spawned)
	spawned.hop()



func _on_ShotTimer_timeout():
	if  is_dying:
		return

	$Graphic/CannonAnimation.play("Fire")
