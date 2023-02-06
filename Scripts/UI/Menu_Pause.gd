extends "res://Scripts/UI/Menu.gd"

export var is_active : bool = true


func _ready():
	TimeManager.add_pause("pausemenu")

func on_close():
	TimeManager.remove_pause("pausemenu")


func _process(_delta):
	
	# Only 
	$Skew/Panel/ItemList.active = is_active  and  (MenuManager.stack[MenuManager.stack.size()-1] == self)
	
	if Input.is_action_just_pressed("ui_cancel"):
		$AnimationPlayer.play("Close")



func on_choose(_node, item):

	match item:

		# Resume
		0:
			$AnimationPlayer.play("Close")

		# Settings
		1:
			var _submenu_instance = MenuManager.open("options")
			#submenu_instance.connect("menu_closed", self, "_on_return")

		# Restart
		2:
			StageManager.begin_restarting()
			$AnimationPlayer.play("Close")

		# Change character
		3:
			StageManager.begin_restarting(true)
			$AnimationPlayer.play("Close")

		# Exit stage
		4:
			StageManager.exit_stage()
			$AnimationPlayer.play("Close")

		_:
			pass
