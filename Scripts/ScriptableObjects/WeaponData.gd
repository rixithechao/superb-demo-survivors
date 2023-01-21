tool
extends EquipmentData
class_name WeaponData

enum WeaponPierceType {
	AREA_OF_EFFECT,
	LIMITED
}

export var projectile : Resource

#export(int, FLAGS, "Might", "Area", "Speed", "Amount", "Duration", "Pierce", "Cooldown", "Interval", "Delay", "Knockback", "Limit", "Chance", "Crit Multiplier") var ignore_stats = 0

#export var damage : float = 10
#export var area : float = 1
#export var speed : float = 1
#export var amount : int = 1
#export var duration : float = 1
export(WeaponPierceType) var pierce_type = WeaponPierceType.AREA_OF_EFFECT 
#export var pierce_count : int = 1
#export var cooldown : float = 1.35
#export var projectile_interval : float = 1
#export var hitbox_delay : float = 1
#export var knockback : float = 0
export var pool_limit : int = 30
#export var effect_chance : float = 0.2
#export var crit_multiplier : float = 2
export var blocked_by_terrain : bool


func get_equipment_type():
	return EquipmentData.EquipmentType.WEAPON


func get_stat_current(stat):
	return PlayerManager.get_stat(stat, self)


func apply_stats(modified, current_level = null):
	return .apply_stats(modified, current_level)
