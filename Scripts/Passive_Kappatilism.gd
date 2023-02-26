extends Equipment


func on_modify_stats(modified):
	var coin_count = PlayerManager.coins
	var percent = min(1, inverse_lerp(0,50, coin_count))
	
	var bonus = lerp(0, 0.3 * (data.get_current_level()), percent)
	
	modified[StatsManager.DAMAGE] += bonus


func _ready():
	PlayerManager.connect("modify_stats", self, "on_modify_stats")
	._ready()
