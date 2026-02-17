class_name Location extends Button


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
	add_to_group(get_script().get_global_name().to_snake_case()) # IDK how to convert it to plural, sry
	#hide()
	Bus.set_location_enabled.connect(_on_bus_set_location_enabled)


func _get_points(_path: Array) -> int:
	return points


@warning_ignore("shadowed_variable")
func lift_fow(view_range := self.view_range) -> void:
	show()
	for i in connected_locations:
		i.show()
		for j in i.connections:
			j.show()
			j.update_gradient()


# Made input argument "valid_types" an array, in case it needs to display the
# valid locations for all the card types you have in hand.
func get_valid_locations(valid_types: Array[Script]) -> Array[Location]:
	@warning_ignore("shadowed_variable")
	return connected_locations.filter(
		func(location: Location) -> bool:
			# Might be about time to split this bad boy into a multi-liner
			return  location.get_script() in valid_types \
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
