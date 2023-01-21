extends "res://Scripts/UI/Menu.gd"


var stage_picked


func _ready():
	UIManager.connect("load_screen_faded_in", self, "_on_load_screen")
	
	var list_ref = $Skew/Panel/ItemList

	list_ref.clear()
	for i in range(0,StageManager.stages.size()):
		var stg = StageManager.stages[i]
		list_ref.add_item(stg.name, null, true)
		list_ref.set_item_tooltip_enabled(i,false)


	#var tween = $Tween
	#tween.interpolate_property($Skew/Panel, "rect_scale",
	#	Vector2(0.75,0.75), Vector2.ONE, 0.75,
	#	Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	#tween.start()


func choose(item):
	stage_picked = item

	#var tween = $Tween
	#tween.interpolate_property($Skew/Panel, "rect_scale",
	#	Vector2.ONE, Vector2(0.01,0.01), 0.75,
	#	Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	#tween.interpolate_property($Skew/Panel, "modulate",
	#	Color.white, Color(1,1,1,0), 0.75,
	#	Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	#tween.start()
	$Skew/Panel/ItemList.active = false
	$ConfirmSound.play()
	
	UIManager.show_load_screen()


func _on_load_screen():
	StageManager.load_stage(StageManager.stages[stage_picked])
	self.close()
