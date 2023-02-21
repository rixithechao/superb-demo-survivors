extends Sprite

export var main_sprite : NodePath
var original_sprite

func _process(_delta):
	if  original_sprite == null:
		original_sprite = get_node(main_sprite) #$"../Sprite"

	position = original_sprite.position
	scale = original_sprite.scale
	rotation_degrees = original_sprite.rotation_degrees
	texture = original_sprite.texture
	centered = original_sprite.centered
	offset = original_sprite.offset
	flip_h = original_sprite.flip_h
	flip_v = original_sprite.flip_v
	hframes = original_sprite.hframes
	vframes = original_sprite.vframes
	frame = original_sprite.frame
	pass
