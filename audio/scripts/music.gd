extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func themes():
	$mus_map.play()
	$mus_map.finished.connect(on_map_theme_finished)


func on_map_theme_finished():
	$mus_pad.play()
	$mus_pad.finished.connect(themes)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
