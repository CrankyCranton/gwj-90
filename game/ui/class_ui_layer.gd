class_name UI_Layer extends Control
signal layer_closing()
signal layer_closed(layer:UI_Layer)
signal layer_opened(layer:UI_Layer)
signal parse_data(data:Dictionary)
signal data_finished_parsing()

var open_data:Dictionary = {}

var is_ready:bool = false
var is_closing:bool = false

@export_category("Mouse Settings")
@export var mouse_mode:Input.MouseMode = Input.MOUSE_MODE_VISIBLE

@export_category("Transition Settings")
@export var uses_open_animation:bool = false
@export var uses_close_animation:bool = false
@export var layer_animations:AnimationPlayer = null
@export var fade_in_time:float = -1.0
@export var fade_out_time:float = -1.0

## Helper functions for UI. Pass data for UI to process if needed.
func add_to_root(parsed_data:Dictionary = {}) -> void:
	UI.root.add_child(self)

	Input.mouse_mode = mouse_mode

	if uses_open_animation:
		assert((layer_animations != null), "uses_open_animation is true; but no animation player selected.")
		assert(layer_animations.has_animation("open"), 'No "close" animation found in player.')
		layer_animations.play("open")
		await layer_animations.animation_finished
	else:
		if fade_in_time > 0.0:
			await _fade(1.0)

	if parsed_data.is_empty():
		is_ready = true
		layer_opened.emit(self)
		return
	else:
		parse_data.emit(parsed_data)


func close_layer() -> void:
	if not is_closing:
		is_ready = true
		is_closing = true
		layer_closing.emit(self)


func _on_data_finished_parsing() -> void:
	is_ready = true
	layer_opened.emit()


func _on_layer_closing(_none:UI_Layer) -> void:
	if uses_close_animation:
		assert((layer_animations != null), "uses_close_animation is true; but no animation player selected.")
		assert(layer_animations.has_animation("close"), 'No "close" animation found in player.')
		layer_animations.play("close")
		await layer_animations.animation_finished
	else:
		if fade_out_time > 0.0:
			await _fade(0.0)

	layer_closed.emit(self)


# Private fader if fade is set to something about 0.0
func _fade(goal:float) -> void:
	var t:Tween = get_tree().create_tween()
	if goal > 0.0:
		t.tween_property(self, "modulate:a", goal, fade_in_time)
	else:
		t.tween_property(self, "modulate:a", goal, fade_out_time)
	await t.finished
