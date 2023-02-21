tool
extends EnemyCharacter


func _ready():
	._ready()
	height = 56
	air_speed = 4

func _process(delta):
	._process(delta)
	if  not is_dying  and  height == 0  and  air_speed <= 0:
		die()

func death_effects():
	.death_effects()
