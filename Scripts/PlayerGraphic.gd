extends CharacterGraphic
class_name PlayerGraphic


enum PlayerAnimState {
	IDLE,
	WALK,
	LOOKING,
	DIE,
	PLUCKING,
	PLUCKED,
	GET,
	SPAWN
}
enum PlayerLookAngle {
	AHEAD,
	UP,
	DOWN
}


export(PlayerAnimState) var state setget _set_anim_state, _get_anim_state
export(PlayerLookAngle) var lookDir = PlayerLookAngle.AHEAD
export(float, 0, 32) var walkSpeed = 1.0
export(bool) var fixed_animation = false
export(bool) var mercy_blinking = true

var _state = PlayerAnimState.IDLE



func death_effects():
	$DeathParticles1.restart()
	$DeathSound.play()




func _ready():
	$AnimationTree.active = true
	$AnimationTree.advance( rand_range(0,4) )



func _process(_delta):
	._process(_delta)
	
	var blonk = floor(fmod(PlayerManager.mercy_seconds*10, 2))
	$AirOffset.modulate.a = (blonk if (PlayerManager.mercy_seconds > 0  and  mercy_blinking) else 1)
	$AnimationTree.set("parameters/looking/current", lookDir)


func _set_anim_state(value):
	if  fixed_animation:
		return

	_state = value
	$AnimationTree.set("parameters/movement/current", value)
func _get_anim_state():
	return $AnimationTree.get("parameters/movement/current")


