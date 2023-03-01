extends Node

var all_characters = [
	load("res://Data Objects/Playables/Playable_Demo.tres"),
	load("res://Data Objects/Playables/Playable_Iris.tres"),
	load("res://Data Objects/Playables/Playable_Sheath.tres"),
	load("res://Data Objects/Playables/Playable_Raocow.tres"),
]



func check_z_overlap(charA, charB):
	return  (charA.get_z_top() >= charB.height  and  charA.height <= charB.get_z_top())
