class_name Connection extends Line2D


@export var selected_width := 8.0
@export var finished_width := 6.0

# TODO Store as an array
var a: Location
var b: Location

@onready var original_color := default_color
@onready var original_width := width
@onready var character: Character = null:
	set(value):
		character = value
		default_color = character.path_color if character else original_color
		width = selected_width if character else original_width
		update_gradient()


func update() -> void:
	set_point_position(0, a.position + a.size * a.scale / 2.0)
	set_point_position(1, b.position + b.size * b.scale / 2.0)


func update_gradient() -> void:
	gradient.set_color(0, default_color if a.visible else Color.TRANSPARENT)
	gradient.set_color(1, default_color if b.visible else Color.TRANSPARENT)


func set_completed() -> void:
	default_color.s /= 3.0
	width = finished_width
	update_gradient()
