extends "res://Scripts/UI/Menu.gd"



var selection = -1

const ITEMS = {
	"START": 0,
	"SHOP": 1,
	"SETTINGS": 2,
	"CREDITS": 3,
	"QUIT": 4
}


func _ready():
	if  MenuManager.pressed_any_key:
		$AnimationPlayer.play("Menu_Title_Return")
	else:
		$AnimationPlayer.play("Menu_Title")
		MenuManager.pressed_any_key = true



func on_choose(_node, item):
	if  selection == ITEMS.SHOP:
		pass
	else:
		selection = item
		$AnimationPlayer.play("Menu_Title_Close")


func perform_choice():
	match selection:
		ITEMS.START:
			next_menu("stages")

		ITEMS.SHOP:
			var submenu_instance = MenuManager.open("options")
			submenu_instance.connect("menu_closed", self, "_on_return")
			
		ITEMS.SETTINGS:
			var submenu_instance = MenuManager.open("options")
			submenu_instance.connect("menu_closed", self, "_on_return")
			
		ITEMS.CREDITS:
			var submenu_instance = MenuManager.open("credits")
			submenu_instance.connect("menu_closed", self, "_on_return")

		ITEMS.QUIT:
			get_tree().quit()
			pass


func _on_return(_node):
	$AnimationPlayer.play("Menu_Title_Return")
