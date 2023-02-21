tool
extends EnemyCharacter
class_name EnemyCharacter_Charger

export var charging_speed_mult : float = 1
export var charging_sheet : Texture

var has_been_hit = false


func on_hit():
	if  has_been_hit:
		return

	has_been_hit = true
	if  charging_sheet != null:
		$Graphic.change_sprites(charging_sheet)

	other_speed_mult = charging_speed_mult
