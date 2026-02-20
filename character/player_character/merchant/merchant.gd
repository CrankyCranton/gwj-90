class_name Merchant extends PlayerCharacter


func _update_character_score() -> void:
	@warning_ignore("integer_division")
	points = floori(paths.back().locations.size() / 5) * 3
