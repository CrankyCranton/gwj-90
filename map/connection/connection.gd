class_name Connection extends GraphElement


@export var selected_width := 8.0

# TODO Store as an array
var a: Location
var b: Location

@onready var line: Line2D = $Line
@onready var original_color := line.default_color
@onready var original_width := line.width
@onready var character: Character = null:
	set(value):
		character = value
		line.default_color = character.path_color if character else original_color
		line.width = selected_width if character else original_width


func update() -> void:
	line.set_point_position(0, a.position_offset + a.size / 2.0)
	line.set_point_position(1, b.position_offset + b.size / 2.0)


func update_gradient() -> void:
	line.gradient.set_color(0, line.default_color if a.visible else Color.TRANSPARENT)
	line.gradient.set_color(1, line.default_color if b.visible else Color.TRANSPARENT)
