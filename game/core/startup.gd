class_name Startup extends Node

func _ready() -> void:
	UI.open_new_layer(&"MAIN_MENU")
	self.queue_free()
