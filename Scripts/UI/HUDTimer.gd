extends Control



func update_timer():
	rect_rotation = rand_range(10,20) * pow(-1, randi() % 2)
	$TimerSecondsOnes.text = String(TimeManager.seconds_passed % 10)
	$TimerSecondsTens.text = String(floor(TimeManager.seconds_passed * 0.1))
	$TimerMinutesOnes.text = String(TimeManager.minutes_passed % 10)
	$TimerMinutesTens.text = String(floor(TimeManager.minutes_passed * 0.1))
	#"%02d" % (10 * floor(TimeManager.seconds_passed * 0.1))

func _on_change_second():
	update_timer()


func _ready():
	TimeManager.connect("new_second", self, "_on_change_second")
	$TimerSecondsOnes.text = "0"
	$TimerSecondsTens.text = "0"
	$TimerMinutesOnes.text = "0"
	$TimerMinutesTens.text = "0"

func _process(_delta):
	rect_rotation = lerp(rect_rotation,0,0.1)
