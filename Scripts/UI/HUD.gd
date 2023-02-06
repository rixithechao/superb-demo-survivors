extends CanvasLayer

var timer
var exp_bar
var weapon_slots
var passive_slots
var debug_info
var money
var kills


func _ready():
	UIManager.hud = self
	timer = $Elements/Timer
	exp_bar = $Elements/ExpBar
	weapon_slots = $Elements/Weapons
	passive_slots = $Elements/Passives
	debug_info = $Elements/DebugInfo
	money = $Elements/Money
	kills = $Elements/Kills
	
	weapon_slots.slots_const = PlayerManager.WEAPON_SLOTS
	passive_slots.slots_const = PlayerManager.PASSIVE_SLOTS
	pass

func _process(_delta):
	if  not StageManager.started:
		return
	
	var alive_alpha_conds = PlayerManager.instance != null and !PlayerManager.dead
	var alive_alpha = (1 if alive_alpha_conds else 0)
	
	timer.modulate.a = alive_alpha
	exp_bar.modulate.a = alive_alpha
	debug_info.modulate.a = alive_alpha
	weapon_slots.modulate.a = alive_alpha
	passive_slots.modulate.a = alive_alpha
	money.modulate.a = alive_alpha
	kills.modulate.a = alive_alpha
	pass
