extends Equipment


const LOW_CHANCE = 0.33
const MID_CHANCE = 0.47
const HIGH_CHANCE = 0.66
const ALL_CHANCE = 0.1

const SHORT_DURATION = 2.5
const LONG_DURATION = 5


func on_crit(signal_data):
	var chance = LOW_CHANCE
	var dur = SHORT_DURATION
	
	match  data.get_current_level():
		2:
			chance = MID_CHANCE
		3:
			chance = MID_CHANCE
			dur = LONG_DURATION
		4:
			chance = HIGH_CHANCE
			dur = LONG_DURATION
	
	if  randf() <= chance:
		signal_data.target.freeze(dur)


func on_hit(signal_data):
	if  data.get_current_level() == data.max_level:
		if  randf() <= ALL_CHANCE:
			signal_data.target.freeze(LONG_DURATION)




func _ready():
	EquipmentManager.connect("on_critical_hit", self, "on_crit")
	HarmableManager.connect("take_hit", self, "on_hit")
