class_name MyBeautifulCard extends Button


@export var icons_lookup: Dictionary[Script, Texture2D]

var type: Script:
	set(value):
		type = value
		if icons_lookup.has(type):
			icon = icons_lookup[type]
