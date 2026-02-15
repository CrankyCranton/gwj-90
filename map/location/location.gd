class_name Location extends Button


@export var random_offset := 24.0


func _ready() -> void:
	position += Utils.rand_vec2_radial(random_offset)
