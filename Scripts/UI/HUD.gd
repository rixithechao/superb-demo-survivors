extends CanvasLayer

var timer
var exp_bar
var weapon_slots
var passive_slots
var boost_slots
var debug_info
var money
var kills




func _ready():
	SaveManager.settings.connect("settings_changed", self, "_on_settings_changed")

	UIManager.hud = self
	timer = $Elements/Timer
	exp_bar = $Elements/ExpBar
	weapon_slots = $Elements/Weapons
	passive_slots = $Elements/Passives
	boost_slots = $Elements/Boosts
	debug_info = $Elements/DebugInfo
	money = $Elements/Money
	kills = $Elements/Kills
	
	weapon_slots.slots_const = PlayerManager.EQUIP_SLOTS
	passive_slots.slots_const = PlayerManager.EQUIP_SLOTS
	boost_slots.slots_const = PlayerManager.EQUIP_SLOTS
	pass

func _process(_delta):
	if  not StageManager.started:
		return
	
	var alive_alpha_conds = !PlayerManager.dead  #and  PlayerManager.instance != null
	var alive_alpha = (1 if alive_alpha_conds else 0)
	
	timer.modulate.a = alive_alpha
	exp_bar.modulate.a = alive_alpha
	debug_info.modulate.a = alive_alpha
	weapon_slots.modulate.a = alive_alpha
	passive_slots.modulate.a = alive_alpha
	boost_slots.modulate.a = alive_alpha
	money.modulate.a = alive_alpha
	kills.modulate.a = alive_alpha


func _on_settings_changed():
	var coin_tex = load("res://Textures/UI/spr_hud_coin_a2xt.png")
	var tooth_tex = load("res://Textures/UI/spr_hud_tooth_a2xt.png")

	$Elements/Money/Sprite.texture = (tooth_tex if  SaveManager.settings.teeth  else coin_tex)

