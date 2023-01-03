extends ProgressBar


func _on_get_exp():
	max_value = PlayerManager.exp_needed
	value = PlayerManager.current_exp


func _ready():
	PlayerManager.connect("get_exp", self, "_on_get_exp")
	_on_get_exp()
