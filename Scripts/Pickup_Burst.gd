extends Pickup
class_name Pickup_Burst


export var instanced_prefab : PackedScene


func pickup_effect():
	var inst = instanced_prefab.instance()
	WorldManager.add_object(inst)
	inst.global_position = PlayerManager.instance.global_position
