tool
extends EnemyCharacter
class_name EnemyCharacter_Hopper

export var spread : float = 10
export var hop_strength : float = 4
export var hop_variance : float = 0.5

var hop_dir : Vector2



func custom_movement():
	var dir
	#print("HOPPIN, ", height, ", ", air_speed)
	
	if  (height <= 0  and  air_speed <= 0):
		var player_pos = PlayerManager.instance.position
		
		var rot = deg2rad(rand_range(-spread, spread))
		dir = (player_pos-position).normalized().rotated(rot)
		hop_dir = dir
		air_speed = hop_strength + rand_range(-hop_variance,hop_variance)*0.5
		#print("\nNEW HOP")

	else:
		dir = hop_dir

	return dir
