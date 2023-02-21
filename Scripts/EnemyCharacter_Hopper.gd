tool
extends EnemyCharacter
class_name EnemyCharacter_Hopper

export var spread : float = 10
export var hop_strength : float = 4
export var hop_variance : float = 0.5
export var hop_decay : float = 0
export (int, -1, 9999) var limited_hops = -1
export var bounce_vfx : PackedScene


var hop_dir : Vector2
var hop_count : int = 9999
var current_hop_strength : float = 99999
var state_machine
var cached_node = "Bounce"


func init_state_machine():
	if  state_machine == null:
		state_machine = $Graphic/AnimationTree["parameters/playback"]


func hop():
	var player_pos = PlayerManager.instance.position

	var rot = deg2rad(rand_range(-spread, spread))
	hop_dir = (player_pos-position).normalized().rotated(rot)
	air_speed = current_hop_strength + rand_range(-hop_variance,hop_variance)*0.5
	$Graphic.mirror = ( sign(hop_dir.x) == -1 )

	current_hop_strength = max(0.1, current_hop_strength-hop_decay)

	if  bounce_vfx != null  and  height == 0:
		VFXManager.spawn(bounce_vfx, position)

	init_state_machine()
	state_machine.travel("Jump")



func custom_movement(delta : float = 0.0):
	init_state_machine()
	
	if  cached_node != state_machine.get_current_node():
		_on_animation_finished(cached_node)
		cached_node = state_machine.get_current_node()


	custom_facing = true

	var dir
	#print("HOPPIN, ", height, ", ", air_speed)

	if  (height <= 0  and  air_speed <= 0):
		dir = Vector2.ZERO
		print("HOPPER STUCK?")
		if  state_machine.get_current_node() != "Bounce":
			print("HOPPER START BOUNCE")
			state_machine.travel("Bounce")

	else:
		dir = hop_dir

	return dir



func _ready():
	hop_count = limited_hops+1
	current_hop_strength = hop_strength
	._ready()


func _on_animation_finished(anim_name):
	print("HOPPER ", name, " FINISHED ", anim_name)
	if  anim_name == "Bounce":

		hop_count = max(hop_count-1, -1)
		if  hop_count == 0:
			die()
		else:
			hop()


	pass # Replace with function body.
