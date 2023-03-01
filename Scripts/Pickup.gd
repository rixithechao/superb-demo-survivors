extends Area2D
class_name Pickup

var burst = false
var collected = false
var effect_applied = false
var magnetized = false
var _tween

const TWEEN_TIME = 0.3
const MAGNET_CRUSH_RADIUS = 4500

func pickup_effect():
	pass
	
func magnetize():
	magnetized = true

func collect():
	if  collected:
		return

	collected = true
	
	_tween.remove (self, "global_position")
	
	_tween.interpolate_property(self, "position",
		self.position, self.position + Vector2.ONE.rotated(deg2rad(rand_range(0,360)))*96, TWEEN_TIME,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
		
	_tween.interpolate_property(self, "scale",
		Vector2.ONE, Vector2.ONE*0.75, TWEEN_TIME,
		Tween.TRANS_QUAD, Tween.EASE_OUT)

	_tween.start()

	$PickupSound.play()


func _on_Pickup_body_entered(_area):
	if  not collected:
		if magnetized:
			collected = true
			$PickupSound.play()
			_on_Tween_tween_completed(null, null)
		else:
			collect()

func _on_Tween_tween_completed(_object, _key):
	if  not collected:
		return

	if  not effect_applied:
		effect_applied = true
		pickup_effect()

		$Sprite.modulate = Color(1,1,1,0)
		$CollectSound.play()

func _on_CollectSound_finished():
	self.queue_free()
	pass # Replace with function body.


func _process(_delta):
	if  not burst:
		burst = true
		_tween.interpolate_property(self, "global_position",
			self.global_position, self.global_position + Vector2.ONE.rotated(deg2rad(rand_range(0,360)))*48, TWEEN_TIME,
			Tween.TRANS_QUAD, Tween.EASE_OUT)
		_tween.start()
	
	if  collected:
		var percent = _tween.tell()/TWEEN_TIME
		
		position = lerp(self.position, PlayerManager.instance.position + Vector2(0,-32), percent)
	elif magnetized:
		var to_player = PlayerManager.instance.position - position
		var distance_to_player = to_player.length()
		
		#instantly teleport candies outside a specific radius so they don't take forever to get there
		if distance_to_player > MAGNET_CRUSH_RADIUS:
			position = PlayerManager.instance.position - to_player.normalized()*MAGNET_CRUSH_RADIUS
		
		position += to_player.normalized() * min(distance_to_player, 28*_delta*60)
	#self.z_index = self.position.y


func _ready():
	_tween = $Tween
