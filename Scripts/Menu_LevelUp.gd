extends Node


func _ready():
	var list_ref = $Panel/ItemList
	
	for i in range(0,list_ref.get_item_count()):
		list_ref.set_item_tooltip_enabled(i,false)

	var tween = get_node("Tween")
	tween.interpolate_property($Panel, "rect_scale",
		Vector2(0.75,0.75), Vector2.ONE, 0.75,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	
	TimeManager.time_rate = 0


func choose(item):
	TimeManager.time_rate = 1
	self.queue_free()
