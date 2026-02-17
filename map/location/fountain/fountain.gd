class_name Fountain extends Location


func _get_points(path: Array) -> int:
	return points + path.filter(func(location: Location) -> bool: return location is Fountain).size()
