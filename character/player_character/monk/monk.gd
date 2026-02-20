class_name Monk extends PlayerCharacter


func _update_character_score() -> void:
	var types: Array[Script] = []
	for l: Location in paths.back().locations:
		if not types.has(l.get_script()):
			types.append(l.get_script())
	points = types.size() * 2
