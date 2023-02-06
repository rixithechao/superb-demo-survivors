extends Control

func update_gfx(new_icon, new_level):
	if new_icon == null:
		$LevelLabel.text = ""
	else:
		$LevelLabel.text = "Lv " + String(new_level)
	$EquipmentIcon.texture = new_icon
	pass
