extends Resource
class_name PlayableData

export var name : String
export var bio : String
export var sprite_sheet : Texture
export(Dictionary) var animations = {idle=Object(), fidget=Object(), look=Object(),lookup=Object(),lookdown=Object(), walk=Object(), die=Object(), pluck1=Object(), pluck2=Object()}
export var starting_weapon : Resource
export var damage = 1.00
export var defense = 1.00
export var max_hp = 100
export var recovery = 1.00
export var cooldown = 1.00
export var weapon_area = 1.00
export var weapon_speed = 1.00
export var weapon_duration = 1.00
export var weapon_count = 1.00
export var move_speed = 1.00
export var pickup_range = 1.00
export var luck = 1.00
export var xp_rate = 1.00
export var money_rate = 1.00


func _ready():
	pass
