extends "res://Scripts/UI/Menu.gd"


var stage_picked


func _ready():
	MusicManager.play(MusicManager.TRACKS.MENU_MAIN)
	UIManager.connect("load_screen_faded_in", self, "_on_load_screen")
	StageManager.update_unlocked_list()
	
	var list_ref = $Skew/Panel/ItemList

	list_ref.clear()
	for i in range(0,StageManager.unlocked.size()):
		var stg = StageManager.unlocked[i]
		list_ref.add_item(stg.name, null, true)
		list_ref.set_item_tooltip_enabled(i,false)

	_on_ItemList_item_hovered(0)



func on_choose(_node, item):
	stage_picked = item

	$Skew/Panel/ItemList.active = false
	$ConfirmSound.play()
	
	MusicManager.fade_out()
	UIManager.show_load_screen()


func _on_load_screen():
	StageManager.load_stage(StageManager.unlocked[stage_picked])
	self.close()


func _on_ItemList_item_hovered(index):
	print("HOVERED: ", index)
	if  StageManager.unlocked.size() == 0:
		return

	var data = StageManager.unlocked[index]
	
	# Stage info
	$Skew/LevelPreview/Unskew/TextureRect.texture = data.preview
	$Skew/ScorePanel/Duration.text = String(data.boss_minute) + ":00"
	$Skew/ScorePanel/Duration/TwoDigitFill.visible = (data.boss_minute >= 10)
	$Skew/ScorePanel/Duration/OneDigitFill.visible = (data.boss_minute < 10)
	

	# Records
	print("SELECTING STAGE: ", data, "\n", SaveManager._stage_map, "\n")
	var save_index = SaveManager._stage_map[data]
	
	var rank_label = $Skew/ScorePanel/Rank
	var time_record_label = $Skew/ScorePanel/TimeRecord

	if  SaveManager.records.ranks.has(save_index):
		rank_label.text = SaveManager.records.ranks[save_index]
	else:
		rank_label.text = "--"


	if  SaveManager.records.longest_times.has(save_index):
		var seconds_total = SaveManager.records.longest_times[save_index]
		var seconds = seconds_total%60
		var minutes = floor(seconds_total/60) as int
		time_record_label.text = String(minutes) + ":" + String(seconds)
	else:
		time_record_label.text = "-- : --"

	pass # Replace with function body.
