extends Equipment
class_name Equipment_Shield




func on_player_hit(event_data):
	pass
func on_player_damage(event_data):
	pass



func _ready():
	PlayerManager.instance.connect("take_hit", self, "on_player_hit")
	PlayerManager.instance.connect("take_damage", self, "on_player_damage")
	._ready()
