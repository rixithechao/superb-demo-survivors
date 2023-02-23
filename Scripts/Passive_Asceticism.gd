extends Equipment


func on_modify_stats(modified):
	var pickup_count = PickupManager.get_count()
	var percent = min(1, inverse_lerp(0,150, pickup_count))
	
	var bonus = lerp(0, 0.5 * (1+data.get_current_level()), percent)
	
	modified[StatsManager.DAMAGE] += bonus


func _ready():
	PlayerManager.connect("modify_stats", self, "on_modify_stats")
	._ready()
