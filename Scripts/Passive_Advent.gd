extends Equipment

var stacks = 0

const REFRESH_DURATION = 5

func update_boxes():
	$Boxes/Box_1.modulate.a = (1 if stacks >= 1 else 0)
	$Boxes/Box_2.modulate.a = (1 if stacks >= 2 else 0)
	$Boxes/Box_3.modulate.a = (1 if stacks >= 3 else 0)
	$Boxes/Box_4.modulate.a = (1 if stacks >= 4 else 0)
	$Boxes/Box_5.modulate.a = (1 if stacks >= 5 else 0)
			
func _on_ResetTimer_timeout():
	stacks = 0
	update_boxes()
	
func on_modify_stats(modified):	
	modified[StatsManager.DAMAGE] += stacks*0.2*lerp(1.0, 2.0, float(data.get_current_level()-1)/4.0) - 0.5
	
func on_change_kills():
	if stacks < 5:
		stacks += 1
		update_boxes()
		
	$ResetTimer.start(REFRESH_DURATION)

func _ready():
	PlayerManager.connect("modify_stats", self, "on_modify_stats")
	EnemyManager.connect("change_kills", self, "on_change_kills")
	._ready()
