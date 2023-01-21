extends CanvasLayer


func _ready():
	UIManager.hud = self
	$Elements/Weapons.slots_const = PlayerManager.WEAPON_SLOTS
	$Elements/Passives.slots_const = PlayerManager.PASSIVE_SLOTS
	pass

func _process(_delta):
	var alive_alpha_conds = PlayerManager.instance != null and !PlayerManager.dead and StageManager.started
	var alive_alpha = (1 if alive_alpha_conds else 0)
	
	$Elements/DebugInfo.modulate.a = alive_alpha
	$Elements/ExpBar.modulate.a = alive_alpha
	$Elements/Weapons.modulate.a = alive_alpha
	$Elements/Passives.modulate.a = alive_alpha
	pass
