class_name Castle extends Location


func _get_points(path: Array) -> int:
	#return 6 if path.size() >= 10 else points
	path = path.duplicate()
	path.erase(self)
	return 0 if path.any(func(location: Location) -> bool: return location is Castle) else points
