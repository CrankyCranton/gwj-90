class_name Forest extends Location


func _draw_card() -> void:
	super()
	CardsManager.burn_card(0)
