extends Node2D

func _process(delta):
	update()

func _draw():
	var yoyo_pos = to_local(get_parent().get_child(1).global_position)
	var player_pos = to_local(PlayerManager.instance.global_position + Vector2(0,-16))
	draw_line(yoyo_pos, player_pos, Color(0,0,0,1), 2.0, 2.0)
