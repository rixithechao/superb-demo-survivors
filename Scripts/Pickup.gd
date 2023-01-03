extends Area2D

var collected = false
var effect_applied = false
var _tween

const TWEEN_TIME = 0.3

func pickup_effect():
	pass


func _on_Pickup_body_entered(area):
	if  not collected:
		collected = true
		_tween = get_node("Tween")
		
		_tween.interpolate_property(self, "position",
			self.position, self.position + Vector2.ONE.rotated(deg2rad(rand_range(0,360)))*96, TWEEN_TIME,
			Tween.TRANS_QUAD, Tween.EASE_OUT)
			
		_tween.interpolate_property(self, "scale",
			Vector2.ONE, Vector2.ONE*0.75, TWEEN_TIME,
			Tween.TRANS_QUAD, Tween.EASE_OUT)
		
		_tween.start()


func _on_Tween_tween_completed(object, key):
	if  not effect_applied:
		effect_applied = true
		pickup_effect()
		
	self.queue_free()


func _process(delta):
	if  collected:
		var percent = _tween.tell()/TWEEN_TIME
		position = lerp(self.position, PlayerManager.instance.position + Vector2(0,-32), percent)
	self.z_index = self.position.y
