extends Node


const PLAYABLE_DEMO = preload("res://Data Objects/Playables/Playable_Demo.tres")
const PLAYABLE_IRIS = preload("res://Data Objects/Playables/Playable_Iris.tres")
const PLAYABLE_SHEATH = preload("res://Data Objects/Playables/Playable_Sheath.tres")
const PLAYABLE_RAOCOW = preload("res://Data Objects/Playables/Playable_Raocow.tres")


var all_characters = [
	PLAYABLE_DEMO,
	PLAYABLE_IRIS,
	PLAYABLE_SHEATH,
	PLAYABLE_RAOCOW,
]



var grouped_characters = {
	"starting": [
		PLAYABLE_DEMO,
		PLAYABLE_IRIS,
		PLAYABLE_SHEATH,
	],
	"unlockable": [
		PLAYABLE_RAOCOW,
	],
}

var unlocked = []



func update_unlocked_list():
	unlocked.clear()
	unlocked.append_array(grouped_characters.starting)
	
	#if  OS.is_debug_build():
	#	unlocked.append(grouped_stages.debug)
	
	# Add each normal stage based on clearing the previous one
	for idx in range(grouped_characters.unlockable.size()):
		var char_data = grouped_characters.unlockable[idx]
		var save_idx = SaveManager._character_map[char_data]

		if  SaveManager.progress.character_unlocks.has(save_idx):
			unlocked.append(char_data)


func unlock_character(char_data):
	var save_idx = SaveManager._character_map[char_data]

	if  not SaveManager.progress.character_unlocks.has(save_idx):
		SaveManager.progress.character_unlocks[save_idx] = true
		SaveManager.progress.save()





func check_z_overlap(charA, charB):
	return  (charA.get_z_top() >= charB.height  and  charA.height <= charB.get_z_top())




func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	StageManager.connect("stage_results", self, "_on_stage_results")


func _on_stage_results(signal_data):
	if  signal_data.cleared:
		unlock_character(PLAYABLE_RAOCOW)
