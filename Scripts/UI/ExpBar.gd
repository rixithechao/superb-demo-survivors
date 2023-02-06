extends TextureProgress


func _on_update_exp_bar():
	max_value = PlayerManager.exp_needed
	value = PlayerManager.current_exp
	$LevelLabel.text = "Level " + String(PlayerManager.level)

func _ready():
	PlayerManager.connect("update_exp_bar", self, "_on_update_exp_bar")
	_on_update_exp_bar()
