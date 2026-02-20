class_name Fighter extends PlayerCharacter


func _get_bonus(_new_location: Location) -> int:
	return 3 if just_killed else 0
