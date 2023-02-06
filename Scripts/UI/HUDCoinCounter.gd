extends HSplitContainer


func _ready():
	PlayerManager.connect("change_coins", self, "_on_change_coins")
	_on_change_coins()
	pass


func _on_change_coins():
	$Label.text = String(PlayerManager.coins)
	pass
