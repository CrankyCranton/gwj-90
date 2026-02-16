extends Node

## Keeps track of currently loaded gameplay scene.
var current_game_scene:Node2D = null

const MAP = preload("uid://rqfjuu0k5g1k")

func _ready() -> void:
	_connect_global_signals()


func _connect_global_signals() -> void:
	pass
