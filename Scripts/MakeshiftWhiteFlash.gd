extends Sprite

func _process(_delta):
	var original_sprite = $"../Sprite"
	position = original_sprite.position
	texture = original_sprite.texture
	centered = original_sprite.centered
	offset = original_sprite.offset
	flip_h = original_sprite.flip_h
	flip_v = original_sprite.flip_v
	hframes = original_sprite.hframes
	vframes = original_sprite.vframes
	frame = original_sprite.frame
	pass
