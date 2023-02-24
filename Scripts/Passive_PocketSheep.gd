extends Equipment

var hit_count = 3
var level = 1
		
func calc_hits(l):
	if l < 3:
		return 3
	elif l < 5:
		return 4
	else:
		return 5
		
func calc_timer(l):
	if l == 1:
		return 10
	elif l < 4:
		return 8
	else:
		return 6

func update_alpha():
	var hitratio = float(hit_count)/calc_hits(data.get_current_level())
	$Graphic.modulate.a = 0.5*hitratio

func on_damage(signal_data):
	if hit_count > 0:
		hit_count -= 1
		signal_data.cancelled = true
			
		$AnimationPlayer.play("default")
		update_alpha()
		
	$ResetTimer.stop()
	$ResetTimer.start(calc_timer(data.get_current_level()))
	
			
func _on_ResetTimer_timeout():
	if hit_count <= 0:
		$Graphic/Sprite.modulate.a = 0
	
	var max_hits = calc_hits(data.get_current_level())
	if hit_count < max_hits:
		$AnimationPlayer.play("respawn")
		
	hit_count = max_hits
	$Graphic.modulate.a = 0.5

func _player_equipment_changed(eqp_type, type_array):
	._player_equipment_changed(eqp_type, type_array)
	if level < data.get_current_level():
		var last_hits = calc_hits(level)
		var new_hits =  calc_hits(data.get_current_level())
		hit_count += new_hits-last_hits
		
		var last_timer = calc_timer(level)
		var new_timer = calc_timer(data.get_current_level())
		var current_timer = $ResetTimer.time_left + new_timer - last_timer
		
		$ResetTimer.stop()
		if current_timer > 0:
			$ResetTimer.start(current_timer)
		else:
			_on_ResetTimer_timeout()

func _ready():
	PlayerManager.connect("take_damage", self, "on_damage")
	PlayerManager.connect("change_equipment", self, "_player_equipment_changed")
