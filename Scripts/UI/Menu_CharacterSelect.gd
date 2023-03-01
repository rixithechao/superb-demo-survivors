extends "res://Scripts/UI/Menu.gd"

onready var button_prefab = preload("res://Prefabs/UI/Prefab_CharacterSelectButton.tscn")


var buttons = []
var current_idx = 0
var data

onready var chars_container = get_node("CharactersCenter/ScrollContainer/Characters")



func _ready():
	
	var i = 0
	var btn_prev
	
	CharacterManager.update_unlocked_list()
	
	for  chara in CharacterManager.unlocked:

		var btn = button_prefab.instance()
		chars_container.add_child(btn)
		buttons.append(btn)

		btn.connect("char_selected", self, "_on_char_selected")
		btn.connect("char_hovered", self, "_on_char_hovered")

		btn.data = chara
		btn.idx = i
		
		if  btn_prev != null:
			btn_prev.focus_neighbour_right = btn.get_path()
			btn.focus_neighbour_left = btn_prev.get_path()

		i += 1
		btn_prev = btn
	pass


func _process(_delta):

	# Navigate
	var nav_change = 0
	
	if  Input.is_action_just_pressed("ui_left"):
		nav_change = -1
	if  Input.is_action_just_pressed("ui_right"):
		nav_change = 1

	if  chars_container.get_focus_owner() == null  and  nav_change != 0:
		current_idx = wrapi(current_idx+nav_change, 0, buttons.size()-1)
		buttons[current_idx].grab_focus()

	if  Input.is_action_just_pressed("ui_select")  and  current_idx != null:
		_on_char_selected(buttons[current_idx])



func _on_char_selected(node):
	PlayerManager.set_character(node.data)
	StageManager.controls_or_spawn_player()
	self.close()

func _on_char_hovered(node):
	current_idx = node.idx
	data = node.data
	$CharacterInfo/BioLabel.text = data.bio
	$CharacterInfo/VBoxContainer/WeaponLabel.text = "Starting weapon:"
	$CharacterInfo/VBoxContainer/WeaponLabel2.text = data.starting_weapon.name
	$CharacterInfo/EquipmentIcon.texture = data.starting_weapon.icon
	$PassiveLabel.text = data.ability_description
