class_name Merchant extends PlayerCharacter


func _get_bonus(_new_location: Location) -> int:
	return 8 * int((paths.back().locations.size() + 1) % 5 == 0)
