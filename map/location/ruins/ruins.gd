class_name Ruins extends Location


@export var abort_chance := 0.25


#func _get_points(path: Array) -> int:
	#@warning_ignore("integer_division")
	#return points - path.size() / 3


func _activate() -> void:
	if randf() <= abort_chance and character is PlayerCharacter:
		character.clear_path()
	super()
