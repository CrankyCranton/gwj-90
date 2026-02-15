class_name Connection extends Line2D


var a: Location
var b: Location

@onready var original_color := default_color
@onready var character: Character = null:
	set(value):
		character = value
		default_color = character.path_color if character else original_color


func update() -> void:
	set_point_position(0, a.position)
	set_point_position(1, b.position)
