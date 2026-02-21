class_name Monk extends PlayerCharacter


func _get_bonus(new_location: Location) -> int:
	var locations_list: Array = paths.back().locations.duplicate()
	locations_list.erase(new_location)
	for l: Location in locations_list:
		if l.get_script() == new_location.get_script():
			return 4
	return 0
