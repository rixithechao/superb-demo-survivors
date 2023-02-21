extends Node

# Drag resources directly into these arrays
var all_weapons = [
	
	# Playable character starting weapons
	preload("res://Data Objects/Equipment/Weapons/Weapon_Leek.tres"),
	preload("res://Data Objects/Equipment/Weapons/Weapon_Knife.tres"),
	preload("res://Data Objects/Equipment/Weapons/Weapon_Cube.tres"),

	# Other
	#preload("res://Data Objects/Equipment/Weapons/Weapon_Lemon.tres"),
	#preload("res://Data Objects/Equipment/Weapons/Weapon_Bangai.tres"),
	#preload("res://Data Objects/Equipment/Weapons/Weapon_Drill.tres"),
	preload("res://Data Objects/Equipment/Weapons/Weapon_Toaster.tres"),
	preload("res://Data Objects/Equipment/Weapons/Weapon_Screwdriver.tres"),
	preload("res://Data Objects/Equipment/Weapons/Weapon_Bee.tres"),
]
var all_passives = [
	preload("res://Data Objects/Equipment/Passives/Passive_ArtificialTime.tres"),
	preload("res://Data Objects/Equipment/Passives/Passive_Asceticism.tres"),
	preload("res://Data Objects/Equipment/Passives/Passive_Cheese.tres"),
	preload("res://Data Objects/Equipment/Passives/Passive_SometimesFood.tres"),
	preload("res://Data Objects/Equipment/Passives/Passive_StrangeCat.tres"),
	preload("res://Data Objects/Equipment/Passives/Passive_Tapestry.tres"),
	#preload("res://Data Objects/Equipment/Passives/Passive_Zebra.tres"),
]
var all_boosts = [
	preload("res://Data Objects/Equipment/Boosts/Boost_Area.tres"),
	preload("res://Data Objects/Equipment/Boosts/Boost_Cooldown.tres"),
	preload("res://Data Objects/Equipment/Boosts/Boost_Damage.tres"),
	preload("res://Data Objects/Equipment/Boosts/Boost_Defense.tres"),
	preload("res://Data Objects/Equipment/Boosts/Boost_Interval.tres"),
	preload("res://Data Objects/Equipment/Boosts/Boost_Movement.tres")
]


signal on_critical_hit



func add(data):
	var spawned = data.prefab.instance()
	spawned.data = data
	PlayerManager.instance.get_node("Equipment").add_child(spawned)
	return spawned
