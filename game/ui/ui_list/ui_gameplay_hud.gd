extends UI_Layer

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	close_layer()
