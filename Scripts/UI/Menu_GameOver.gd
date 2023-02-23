extends "res://Scripts/UI/Menu.gd"


var change_character = false

var show_dead_list = false



func show_node(path : NodePath, dont_play_sound : bool = false):
	var this_node = get_node(path)
	this_node.modulate.a = 1

	var tween = $Tween
	tween.interpolate_property(this_node, "rect_scale",
		Vector2(0,0.75), Vector2.ONE, 0.25,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	
	if  not dont_play_sound:
		$ResultSound.play()



func show_rank():
	if  StageManager.cleared:
		show_node("Control/Results/CenterContainer/Rank", true)
		$RankSound.play()

func show_item_list():
	var list
	show_node("Control/ItemLists")
	if  show_dead_list:
		list = $Control/ItemLists/DeathList
	else:
		list = $Control/ItemLists/ClearList
	
	list.active = true
	list.grab_focus()





func _ready():
	$Control/ItemLists/ClearList.active = false
	$Control/ItemLists/DeathList.active = false
	
	# Teeth or coins
	var coin_tex = load("res://Textures/UI/spr_hud_coin_a2xt.png")
	var tooth_tex = load("res://Textures/UI/spr_hud_tooth_a2xt.png")

	$Control/Results/HBoxContainer/VBoxContainer/Coins/Icons.texture = (tooth_tex if  SaveManager.settings.teeth  else coin_tex)
	$Control/Results/HBoxContainer/VBoxContainer/Coins/Name.text = ("Teeth" if  SaveManager.settings.teeth  else "Coins")

	# Set results
	$Control/Results/HBoxContainer/VBoxContainer/Time/Value.text = String(TimeManager.minutes_passed) + ":" + String(TimeManager.seconds_passed)
	$Control/Results/HBoxContainer/VBoxContainer/Level/Value.text = String(PlayerManager.level)
	$Control/Results/HBoxContainer/VBoxContainer/Coins/Value.text = String(PlayerManager.coins)
	$Control/Results/HBoxContainer/VBoxContainer/Kills/Value.text = String(EnemyManager.kills)
	$Control/Results/HBoxContainer/VBoxContainer/Revives/Value.text = String(PlayerManager.revives)
	
	var wepnz = $Control/Results/HBoxContainer/Equipment/Weapons
	wepnz.slots_const = PlayerManager.EQUIP_SLOTS
	wepnz._on_get_equipment(EquipmentData.EquipmentType.WEAPON, PlayerManager.equipment.weapons)

	var pasvz = $Control/Results/HBoxContainer/Equipment/Passives
	pasvz.slots_const = PlayerManager.EQUIP_SLOTS
	pasvz._on_get_equipment(EquipmentData.EquipmentType.PASSIVE, PlayerManager.equipment.passives)

	var bootz = $Control/Results/HBoxContainer/Equipment/Passives
	bootz.slots_const = PlayerManager.EQUIP_SLOTS
	bootz._on_get_equipment(EquipmentData.EquipmentType.BOOST, PlayerManager.equipment.boosts)

	
	# The player has cleared the stage
	if  StageManager.cleared:
		$Control/Header/DeathHeader.modulate.a = 0

		# Final results
		if  PlayerManager.dead:
			$Control/Header/ClearHeader.text = "FINAL RESULTS"
			$Control/Header/ClearHeader/ClearHeaderBack.text = "FINAL RESULTS"
			$Control/ItemLists/ClearList.visible = false#modulate.a = 0
			show_dead_list = true

		# Stage clear, keep playing?
		else:
			# Except endless mode is now post-birthday, gotta dummy it out
			show_dead_list = true
			$Control/ItemLists/ClearList.visible = false#modulate.a = 0
			#$Control/ItemLists/DeathList.visible = false#modulate.a = 0
	
	# The player died before beating the stage's final boss
	else:
		$Control/Header/ClearHeader.modulate.a = 0
		$Control/ItemLists/ClearList.visible = false#modulate.a = 0
	
	TimeManager.add_pause("gameover")



func on_close():
	TimeManager.remove_pause("gameover")



func on_choose(node, item):

	# Died, so can't keep going
	var death_change = 0

	if show_dead_list:
		death_change = 1


	# Close self
	$AnimationPlayer.play("Sequence_CloseGameOver")
	var death_bg_inst = MenuManager.instances_by_name["deathbg"]
	death_bg_inst.get_node("AnimationPlayer").play("Fade_Out")

	match (item+death_change):

		# Keep going
		0:
			StageManager.keep_going()
			MusicManager.resume()

		# Restart
		1:
			StageManager.begin_restarting()

		# Change character
		2:
			StageManager.begin_restarting(true)

		# Exit stage
		3:
			StageManager.exit_stage()

