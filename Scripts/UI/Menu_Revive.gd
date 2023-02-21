extends "res://Scripts/UI/Menu.gd"


var selection
var cost


const DIALOGUE_OPENINGS = {
	"sequential": [
		"Oh dear, did someone have a little accident?",
		"So we meet again...",
		"Oh, that was quick! Welcome back!",
		"I was wondering when you'd drop by again!",
		"Oh! I wasn't expecting you just yet.",
		"You have just the worst luck, huh?",
		"We really should stop meeting like this, darling.",
	],

	"random": [
		"Hello again.",
		"Hello again, dear!",
		"Nice to see you again!",
		"Nice to see you again, dear!",
		"Greetings!",
	]
}

const DIALOGUE_PROMPTS = {
	# 0 revives
	0: [
		# These combine with the first pages
		["You know, I could... [wave amp=50 freq=2]overlook[/wave]\nthat death. For a price."],
		["Perhaps you'd like me to bring you back [i]this[/i] time? I can make it happen."],
		["I don't suppose you'd like to give it another go?"],

		# These don't
		["Hey, real talk? I appreciate you being such a good sport about dying.","Most would jump at the chance to keep going, but you accept defeat with such [wave amp-50 freq=2]grace[/wave].","Here, this one's on the house. This is the only freebie, though."],
		["Welcome back! My offer's still open if you're interested.","One undone death, free of charge!"],
		["And here we are again!","I take it you won't be needing the revive, will you?"],
		["The way you've been resisting revival so far is impressive!","Still, I'm curious how long you can keep turning down a free revival."],
		["I know what you're doing. You're trying to unlock something, aren't you?","An achievement, or a special secret...","Well, I'm afraid to say, dear gamer, you've given up those free revives for nothing.","This is the last unique dialogue in this branch. After this I'm moving on.","Take the freebie or don't. Either way, the fee returns next time!"]
	],
	
	1: [
		["Not ready to quit? I suppose I can make another exception..."],
	],

	2: [
		["Want another pick-me-up, dear? Third time's the charm!"],
	],

	3: [
		["Do you need my help? My purse has been feeling a touch light lately..."],
	],

	4: [
		["Here for the usual?"],
	],
	
	# 5+ revives (or exhausting the other options)
	"random": [
		["Are you in need of my services or just passing through?"],
		["Want me to roll back your demise today?"],
		["Shall I do the thing?"],
		["Need some help?"],
		["I can get you back in the fight, just say the word."]
	]
}


const NO_STRINGS = [
	"I'm good, thanks",
	"Nope",
	"Maybe another time",
	"Nah",
	"Thanks, but no"
]


func assemble_dialogue():
	var openings = SaveManager.serac.openings
	var _meetings = SaveManager.serac.meetings
	var revives = SaveManager.serac.revives
	var refusals = SaveManager.serac.refusals_current

	var assembled_pages = []

	var opening
	var added
	
	# Determine the opening page
	if  openings < DIALOGUE_OPENINGS.sequential.size():
		opening = DIALOGUE_OPENINGS.sequential[openings]
	else:
		opening = DIALOGUE_OPENINGS.random[randi()%DIALOGUE_OPENINGS.random.size()]

	# Abstinence branch stops adding openings and becomes free, so only append and increment the counter if not on that branch
	var is_free = false
	if  revives == 0  and  refusals > 2:
		is_free = true
	else:
		assembled_pages.append(opening)
		SaveManager.serac.openings += 1

	# Determine the added pages
	if  DIALOGUE_PROMPTS.has(revives)  and  refusals < DIALOGUE_PROMPTS[revives].size():
		added = DIALOGUE_PROMPTS[revives][refusals]
		
		# If serac's giving the freebie, change the cost
		if  is_free:
			cost = 0
	else:
		added = DIALOGUE_PROMPTS.random[randi()%DIALOGUE_OPENINGS.random.size()]

	# Append the added pages
	assembled_pages.append_array(added)

	# Pass the resulting array into the speech bubble
	$"Serac/Message Box".text_body = assembled_pages

	SaveManager.serac.meetings += 1
	SaveManager.serac.save()



func _ready():
	cost = PlayerManager.get_revive_cost()
	assemble_dialogue()
	
	var list_ref = $Skew/List/ItemList

	list_ref.set_item_text(0, "Revive (-" + String(cost) + " " + ("teeth" if  SaveManager.settings.teeth  else  "coins") + ")")
	list_ref.set_item_disabled(0, PlayerManager.coins < cost)

	var random_no = NO_STRINGS[randi() % NO_STRINGS.size()]
	list_ref.set_item_text(1, random_no)

	TimeManager.add_pause("revive")



func on_choose(_node, item):
	selection = item
	
	# Accept
	if  selection == 0:
		var death_bg_inst = MenuManager.instances_by_name["deathbg"]
		death_bg_inst.get_node("AnimationPlayer").play("Fade_Out")
		pass
		SaveManager.serac.refusals_current = 0
		SaveManager.serac.revives += 1

	# Refuse
	else:
		SaveManager.serac.refusals_current += 1
		SaveManager.serac.refusals_total += 1
		pass

	SaveManager.serac.save()

	$AnimationPlayer.play("Menu_Revive_Close")


func on_close():
	# Revive
	if  selection == 0:
		PlayerManager.give_coins(-cost)
		TimeManager.remove_pause("revive")
		PlayerManager.revive()

	# Give up
	else:
		MenuManager.open("gameover")
