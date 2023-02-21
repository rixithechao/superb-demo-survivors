extends Node2D
class_name Shockwave


export var group_affected : String = "enemy"
export var speed : float = 1
export var thickness : float = 128
export var max_size : float = 2048
export var ignore_height : bool = true

var radius = 0.01

var outer_shape
var outer_area

var inner_shape
var inner_area

var ring_sprite

var touched_nodes = []



func on_object_touched(_object_node):
	pass



func _ready():
	outer_shape = $OuterCircle/Shape.shape
	outer_area = $OuterCircle

	inner_shape = $InnerCircle/Shape.shape
	inner_area = $InnerCircle

	ring_sprite = $RingSprite

	var affected_nodes = get_tree().get_nodes_in_group(group_affected)
	#print("SHOCKWAVE CHECKING ", affected_nodes)


func _process(delta):
	radius += delta*speed*1024

	inner_shape.radius = max(0.01, radius - thickness)
	outer_shape.radius = radius
	ring_sprite.scale = Vector2.ONE * (radius/128)

	#print("SHOCKWAVE SIZE = ", radius, ", ", outer_shape.radius, ", ", inner_shape.radius)

	var affected_nodes = get_tree().get_nodes_in_group(group_affected)
	for member in affected_nodes:
		var dist = (member.position - position).length()
		var grounded = ("height" in member  and  member.height == 0  and  "air_speed" in member  and  member.air_speed <= 0)  or  not ("height" in member)

		var touching = dist <= outer_shape.radius  and  dist >= inner_shape.radius #outer_area.overlaps_body(member)  and  not inner_area.overlaps_body(member)

		if  touching and not touched_nodes.has(member):
			#print("SHOCKWAVE TOUCHED ", member)
			touched_nodes.append(member)
			on_object_touched(member)

	if  radius >= max_size + thickness:
		self.queue_free()
