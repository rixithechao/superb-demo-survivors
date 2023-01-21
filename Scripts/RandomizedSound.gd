extends AudioStreamPlayer

export(Array, AudioStream) var sounds
export(float, 0,1) var pitch_range = 0.2


func randomize():
	self.pitch_scale = 1 + rand_range(-pitch_range,pitch_range)

	if sounds.size() > 0:
		self.stream = sounds[randi() % sounds.size()]

	pass


func play(time : float = 0.0):
	randomize()
	.play(time)
