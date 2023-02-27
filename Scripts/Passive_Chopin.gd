extends Equipment

var effect = preload("res://Prefabs/VFX/Prefab_VFX_Chopin.tscn")

var chances = [ 0.1, 0.15, 0.2, 0.25, 0.3 ]

func on_hit(signal_data):
	if  randf() <= chances[data.get_current_level()-1]:
		signal_data.override_crit = true
		VFXManager.spawn(effect, signal_data.target.position)




func _ready():
	HarmableManager.connect("take_hit", self, "on_hit")
