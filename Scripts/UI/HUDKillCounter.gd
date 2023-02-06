extends HSplitContainer


func _ready():
	EnemyManager.connect("change_kills", self, "_on_change_kills")
	_on_change_kills()
	pass


func _on_change_kills():
	$Label.text = String(EnemyManager.kills)
	pass
