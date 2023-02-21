extends Hazard


export var stats : Resource


func apply_hazard(body):
	pass

func apply_hazard_start(body):
	pass

func apply_hazard_end(body):
	pass


func _ready():
	PlayerManager.connect("modify_stats", self, "modify_player_stats")


func modify_player_stats(modified):
	if  overlapping_bodies.has(PlayerManager.instance):

		stats.apply_stats(modified)
		#print("HAZARD: ", signal_data.stats, "\n")
