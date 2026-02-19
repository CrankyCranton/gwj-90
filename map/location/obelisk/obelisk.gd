class_name Obelisk extends Location


#func _get_points(path: Array) -> int:
	#@warning_ignore("integer_division")
	#return points + path.size() / 3


func _activate() -> void:
	if not character is PlayerCharacter:
		return
	var inns := get_tree().get_nodes_in_group(&"inn").filter(
			func(inn: Inn) -> bool: return inn.claim == null and inn.character == null)
	if inns.size() > 0:
		character.clear_path()
		character.set_location(inns.pick_random())
	super()
