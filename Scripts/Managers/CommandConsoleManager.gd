extends Node

var logged_strings = []
var regex = RegEx.new()


signal new_log_entry
signal triggered_new_menu



func log_text(text):
	logged_strings.append(text)
	emit_signal("new_log_entry", text)


func get_log_as_string():
	var combined = ""
	for entry in logged_strings:
		combined = entry + "\n" + combined
	
	return combined


func run_command(text):
	var results = []
	for result in regex.search_all(text):
		results.push_back(result.get_string())
	
	if results.size() > 0:
		print ("COMMAND ENTERED: ", results)
		
		match results[0]:
			"win":
				StageManager.clear_stage()
				log_text(results[0])
				emit_signal("triggered_new_menu")

			"die":
				if  results.size() > 1  and  results[1].is_valid_integer():
					match int(results[1]):
						1:
							PlayerManager.show_serac = true

						2:
							StageManager.cleared = true

						_:
							pass

				PlayerManager.set_hp(0)
				log_text(results[0])
				emit_signal("triggered_new_menu")

			"level_up":
				log_text(results[0])
				PlayerManager.current_exp = 0
				PlayerManager.level_up()
				emit_signal("triggered_new_menu")
				pass

			"set_coins":
				if results.size() > 1  and  results[1].is_valid_integer():
					log_text(text)
					PlayerManager.set_coins(int(results[1]))
				
				elif results.size() > 1:
					log_text("Invalid number of coins")

				else:
					log_text("No value specified")
				pass

			"add_coins":
				if results.size() > 1  and  results[1].is_valid_integer():
					log_text(text)
					PlayerManager.give_coins(int(results[1]))
				
				elif results.size() > 1:
					log_text("Invalid number of coins")

			"set_time":
				if results.size() > 1  and  results[1].is_valid_integer():
					log_text(text)
					TimeManager.current_time = int(results[1])
				
				elif results.size() > 1:
					log_text("Invalid number of seconds")

				else:
					log_text("No value specified")
				pass

			"add_time":
				if results.size() > 1  and  results[1].is_valid_integer():
					log_text(text)
					TimeManager.current_time += int(results[1])
				
				elif results.size() > 1:
					log_text("Invalid number of seconds")

				else:
					log_text("No value specified")
				pass


			# EQUIPMENT
			"weapon":
				if  results.size() > 1:
					if  results[1].is_valid_integer()  and  int(results[1]) < 	EquipmentManager.all_weapons.size():
						log_text(text)
						PlayerManager.give_weapon(EquipmentManager.all_weapons[int(results[1])])
					
					elif results[1] == "start":
						PlayerManager.give_weapon(PlayerManager.data.starting_weapon)

					elif results.size() > 1:
						log_text("Invalid weapon ID")

				else:
					log_text("No weapon ID specified")

			"passive":
				if  results.size() > 1:
					if  results[1].is_valid_integer()  and  int(results[1]) < 	EquipmentManager.all_passives.size():
						log_text(text)
						PlayerManager.give_passive(EquipmentManager.all_passives[int(results[1])])

					elif results.size() > 1:
						log_text("Invalid passive ID")

				else:
					log_text("No weapon ID specified")

			"boost":
				if  results.size() > 1:
					if  results[1].is_valid_integer()  and  int(results[1]) < 	EquipmentManager.all_boosts.size():
						log_text(text)
						PlayerManager.give_boost(EquipmentManager.all_boosts[int(results[1])])

					elif results.size() > 1:
						log_text("Invalid boost ID")

				else:
					log_text("No boost ID specified")


			# NO VALID COMMAND
			_:
				log_text("Command not recognized: \'" + results[0] + "\'\n")
				pass
		
	else:
		log_text("Invalid formatting: \'" + text + "\'\n")



func _ready():
	
	regex.compile("[^\\(\\)\\,\\s]+")
