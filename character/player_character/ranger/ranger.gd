class_name Ranger extends PlayerCharacter


@export var view_bonus := 1


func set_location(new_location: Location) -> void:
	new_location.view_range += view_bonus
	await super(new_location)
	new_location.view_range -= view_bonus
