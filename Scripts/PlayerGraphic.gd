extends "res://Scripts/CharacterGraphic.gd"


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
export(float, 0, 32) var walkSpeed = 1.0


func _process(_delta):
	._process(_delta)
	
	
	pass
