class_name MyBeautifulCard extends Button


var type: Script:
	set(value):
		type = value
		if Location.icons_lookup.has(type):
			icon = Location.icons_lookup[type]
