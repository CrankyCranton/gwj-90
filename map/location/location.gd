class_name Location extends Button


static var icons_lookup: Dictionary[Script, Texture2D] = {
	null: preload("uid://c57cnquykwost"),
}

@export var points := 1
@export var view_range := 1
@export_group("Movement")
@export var can_retravel_connections := false
@export var can_move_onto_other_character := false
@export var can_revisit_location := false

var character: Character = null
var claim: Character = null
var connections: Array[Connection]
var connected_locations: Array[Location]


func _ready() -> void:
	if not icons_lookup.has(get_script()):
		icons_lookup[get_script()] = icon
	add_to_group(get_script().get_global_name().to_snake_case()) # IDK how to convert it to plural, sry
	hide()
	Bus.set_location_enabled.connect(_on_bus_set_location_enabled)


func _get_points(_path: Array) -> int:
	return points


func _draw_card() -> void:
	CardsManager.draw_card()


@warning_ignore("shadowed_variable")
func lift_fow(on := self, view_range := self.view_range) -> void:
	view_range -= 1
	on.show()
	for i in on.connected_locations:
		for j in i.connections:
			j.show()
			j.update_gradient()
		if view_range >= 0:
			lift_fow(i, view_range)


# Made input argument "valid_types" an array, in case it needs to display the
# valid locations for all the card types you have in hand.
## Null is a wildcard.
func get_valid_locations(valid_types: Array[Script] = []) -> Array[Location]:
	@warning_ignore("shadowed_variable")
	return connected_locations.filter(
		func(location: Location) -> bool:
			# Might be about time to split this bad boy into a multi-liner
			return  (self is Hill or location is Lake or valid_types.has(null) \
					or location.get_script() in valid_types) \
					and (can_move_onto_other_character or location.character == null) \
					and (can_revisit_location or location.claim == null) \
					and (can_retravel_connections or
					get_connection_to_location(location).character == null)
	)


func is_connected_to_location(location: Location) -> bool:
	return location in connected_locations


func get_connection_to_location(location: Location) -> Connection:
	for connection: Connection in connections:
		if location in [connection.a, connection.b]:
			return connection
	return null


func _on_bus_set_location_enabled(location: Location, enabled: bool) -> void:
	if location != self:
		return
	disabled = not enabled
	focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	if not enabled:
		release_focus()


func _on_focus_entered() -> void:
	Bus.location_selected.emit(self)


func _on_focus_exited() -> void:
	Bus.location_deselected.emit(self)
