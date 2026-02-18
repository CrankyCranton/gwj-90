class_name Camera extends Camera2D


@export var zoom_speed := 14.0
@export var zoom_strength := 1.17
@export var max_zoom := 3.0
@export var min_zoom := 0.3
@export var limit_margin := 512
@export var limit_smoothing := 5.0

var limits: Rect2i

@onready var target_zoom := zoom


func _process(delta: float) -> void:
	# TODO Multiply by screen resolution if the screen resolution is variable
	@warning_ignore("narrowing_conversion")
	var scaled_limits := limits.grow(limit_margin / zoom.x)
	var target_limits: Dictionary[String, int] = {
		"left": scaled_limits.position.x,
		"right": scaled_limits.end.x,
		"top": scaled_limits.position.y,
		"bottom": scaled_limits.end.y,
	}
	for direction in target_limits:
		var limit := "limit_" + direction
		set(limit, lerpf(get(limit), target_limits[direction], limit_smoothing * delta))

	position = get_screen_center_position()
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_pressed(&"pan"):
		position -= event.screen_relative / zoom
	if event.is_action_pressed(&"zoom_in"):
		adjust_zoom(target_zoom * zoom_strength)
	elif event.is_action_pressed(&"zoom_out"):
		adjust_zoom(target_zoom / zoom_strength)


func adjust_zoom(new_zoom: Vector2) -> void:
	target_zoom = new_zoom.clampf(min_zoom, max_zoom)
