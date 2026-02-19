class_name Forest extends Location


func _draw_card() -> void:
	#CardsManager.burn_card(0)
	Bus.add_bandit.emit()
	super()
