extends Node2D

enum PlayerAnimState {
	IDLE,
	FIDGET,
	WALK,
	LOOKING,
	DIE,
	PLUCKING,
	PLUCKED
}
enum PlayerLookAngle {
	AHEAD,
	UP,
	DOWN
}


export(PlayerAnimState) var state = PlayerAnimState.IDLE
export(PlayerLookAngle) var lookDir = PlayerLookAngle.AHEAD
export(float, 0, 32) var walkSpeed = 1


func _ready():
	pass
