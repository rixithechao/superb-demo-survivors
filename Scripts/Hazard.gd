extends Area2D
class_name Hazard



export var active : bool = true
var overlapping_bodies = []


func apply_hazard(body):
	pass

func apply_hazard_start(body):
	pass

func apply_hazard_end(body):
	pass




func _on_Hazard_body_entered(body):
	overlapping_bodies.append(body)
	print(body.name, " ENTERED HAZARD ", name, "\n", overlapping_bodies)
	apply_hazard_start(body)

func _on_Hazard_body_exited(body):
	overlapping_bodies.erase(body)
	print(body.name, " LEFT HAZARD ", name, "\n", overlapping_bodies)
	apply_hazard_end(body)



func _process(_delta):
	if  not active:
		return

	for  body in overlapping_bodies:
		apply_hazard(body)
