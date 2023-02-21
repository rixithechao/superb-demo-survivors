extends Node2D
class_name VFX

export var autoplay : bool = true
export (Array, NodePath) var particles_paths



func on_play():
	pass

func play():
	for path in particles_paths:
		var node = get_node(path)
		node.restart()
		node.emitting = true

	$AnimationPlayer.play("Sequence")

func start():
	play()


func _ready():
	if  autoplay:
		play()
