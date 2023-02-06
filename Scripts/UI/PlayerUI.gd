extends Node2D


const FINAL_ALPHA_HP = 0.6
const FINAL_ALPHA_AIM = 0.5

const HP_BAR_BULGE = 1.5
const HP_BAR_TIME = 0.25


func _process(_delta):
	$HPBar.value = PlayerManager.hp
	$HPBar.max_value = PlayerManager.get_stat(StatsManager.MAX_HP)

	if  PlayerManager.dead  or  PlayerManager.instance == null:
		$FacingArrowLock.modulate.a = 0
		$FacingArrow.modulate.a = 0
		$HPBar.modulate.a = 0
		return

	var pinst = PlayerManager.instance
	self.global_position = pinst.global_position

	var hp_fade_percent = $HPBarFadeTimer.time_left/HP_BAR_TIME

	$HPBar.modulate.a = lerp(FINAL_ALPHA_HP, 1, hp_fade_percent)
	$HPBar.rect_scale = Vector2.ONE * lerp(1, HP_BAR_BULGE, hp_fade_percent)
	$FacingArrowLock.modulate.a = (pinst.lock_alpha) * FINAL_ALPHA_AIM
	$FacingArrow.modulate.a = (1-pinst.lock_alpha) * FINAL_ALPHA_AIM
	$FacingArrow.rect_rotation = rad2deg(pinst.last_facing_arrow.angle())
	$FacingArrowLock.global_position = $FacingArrow/Sprite.global_position



func _on_HPBar_value_changed(_value):
	$HPBarFadeTimer.start()
	pass # Replace with function body.
