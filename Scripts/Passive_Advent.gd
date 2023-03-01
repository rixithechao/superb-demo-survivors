extends Equipment

var stacks = 0

const REFRESH_DURATION = 5

const ONE_OVER_LOG4 = 1.0/log(4)

func update_boxes():
	for i in 16:
		get_node(str("Boxes/Box_",i+1)).modulate.a = (1 if stacks > i else 0)
			
func _on_ResetTimer_timeout():
	stacks = 0
	update_boxes()
	
func on_modify_stats(modified):	
	#modified[StatsManager.DAMAGE] += stacks*0.2*lerp(1.0, 2.0, float(data.get_current_level()-1)/4.0) - 0.5
	
	var modifier
	if stacks == 0:
		modifier = 0
	elif stacks == 1:
		modifier = 0.25
	else:
		modifier = log(stacks)*ONE_OVER_LOG4
	modified[StatsManager.DAMAGE] += modifier - 0.5

func on_change_kills():
	if stacks < 3*data.get_current_level() + 1:
		stacks += 1
		get_node(str("Boxes/Box_",stacks)).frame = randi()%6
		update_boxes()
		
	$ResetTimer.start(REFRESH_DURATION)
	
func _process(delta):
	if not $Boxes/AnimationPlayer.is_playing() and PlayerManager.instance.get_node("Graphic").state == PlayerGraphic.PlayerAnimState.WALK:
		$Boxes/AnimationPlayer.play("bounce")

func _ready():
	PlayerManager.connect("modify_stats", self, "on_modify_stats")
	EnemyManager.connect("change_kills", self, "on_change_kills")
	$Boxes.position.y = PlayerManager.instance.get_node("HeadMarker").position.y
	._ready()
