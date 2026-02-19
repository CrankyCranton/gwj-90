class_name Grass extends Location


#func _draw_card() -> void:
	#for i in 2:
		#super()


func _get_points(path: Array) -> int:
	return points + path.size() - (path.find(self) + 1)
