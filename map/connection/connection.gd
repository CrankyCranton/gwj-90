class_name Connection extends Line2D


var a: Location
var b: Location


func update() -> void:
	set_point_position(0, a.position)
	set_point_position(1, b.position)
