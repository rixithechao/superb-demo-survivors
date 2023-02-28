extends Area2D
class_name Pickup

var burst = false
var collected = false
var effect_applied = false
var _tween

const TWEEN_TIME = 0.3

var modified_tween_time

func pickup_effect():
	pass

func get_modified_tween_time():
	if modified_tween_time == null:
		modified_tween_time = TWEEN_TIME * clamp((PlayerManager.instance.position-self.position).length()/500, 1, 4)
	return modified_tween_time

func collect():
	if  collected:
		return

	collected = true
	
	modified_tween_time = null
	get_modified_tween_time()
	
	_tween.remove (self, "global_position")
	
	_tween.interpolate_property(self, "position",
		self.position, self.position + Vector2.ONE.rotated(deg2rad(rand_range(0,360)))*96, modified_tween_time,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
		
	_tween.interpolate_property(self, "scale",
		Vector2.ONE, Vector2.ONE*0.75, modified_tween_time,
		Tween.TRANS_QUAD, Tween.EASE_OUT)

	_tween.start()

	$PickupSound.play()


func _on_Pickup_body_entered(_area):
	if  not collected:
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
		var percent = _tween.tell()/get_modified_tween_time()
		
		position = lerp(self.position, PlayerManager.instance.position + Vector2(0,-32), percent)
	#self.z_index = self.position.y


func _ready():
	_tween = $Tween
