extends Control

export var font_main : Font
export var font_small : Font

func update_gfx(new_icon, new_level, max_level):
	#$LevelLabel.rect_scale.x = 1
	$LevelLabel.add_font_override("font",font_main)
	
	if    new_icon == null:
		$LevelLabel.text = ""

	elif  new_level > max_level:
		$LevelLabel.add_font_override("font",font_small)
		$LevelLabel.text = "M+" + String(new_level-max_level)

	elif  new_level == max_level:
		$LevelLabel.add_font_override("font",font_small)
		$LevelLabel.text = "MAX"

	else:
		$LevelLabel.text = "Lv " + String(new_level)

	$EquipmentIcon.texture = new_icon
