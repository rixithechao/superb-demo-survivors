extends "res://Scripts/UI/Menu.gd"


var equipment
var descriptions = ["","",""]


func _ready():
	print("LEVEL UP!\n")

	var list_ref = $Skew/Panel/ItemList
	
	var equipment_roll = PlayerManager.roll_equipment(3, false, true)
	equipment = equipment_roll.selected
	
	list_ref.clear()
	for i in range(0,equipment.size()):
		var eqp = equipment[i]
		var name = eqp.name
		
		var next_level = 1
		if  PlayerManager.equipment_levels.has(eqp):
			next_level = PlayerManager.equipment_levels[eqp]+1
			name = "(Lv. " + String(next_level) + ") " + eqp.name
			
		var desc = eqp.description
		if  next_level >= 2  and  eqp._level_modifiers != null  and  eqp._level_modifiers.size() > next_level-2:
			var next_mod = eqp._level_modifiers[next_level-2]
			print(next_mod, ", ", next_mod.description)
			desc = next_mod.description

		descriptions[i] = desc

		print("EQUIPMENT=", equipment, ", EQP=",eqp, ", i=", i)

		list_ref.add_item(name, eqp.icon)
		list_ref.set_item_tooltip_enabled(i,false)


	var tween = get_node("Tween")
	tween.interpolate_property($Skew/Panel, "rect_scale",
		Vector2(0.75,0.75), Vector2.ONE, 0.75,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	
	TimeManager.add_pause("levelup")


func _process(_delta):
	pass


func on_choose(_node, item):
	PlayerManager.give_equipment(equipment[item])
	TimeManager.remove_pause("levelup")
	PlayerManager.check_for_level_up()
	close()


func _on_ItemList_item_hovered(index):
	print(descriptions, ", ", index)
	$Skew/Panel/Description.text = descriptions[index]
	pass # Replace with function body.
