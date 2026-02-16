# Might have to make a look-up dictionary/array for the textures that apply to each type.
# If that's too inconvenient, it'll probably be better to make each type it's own inherited scene,
# like with the characters.
class_name Location extends TextureButton


enum Type {
	GRASS,
	TREE,
	LAKE,
	HILL,
	CAVE,
	INN,
	RELIC,
	OBELISK,
	TEMPLE,
}

var type := (randi() % Type.size()) as Type

var character: Character = null
var claim: Character = null
var connections: Array[Connection]
var connected_locations: Array[Location]


func _ready() -> void:
	Bus.set_location_enabled.connect(_on_bus_set_location_enabled)


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

	visible = enabled
	disabled = not enabled
	if not enabled:
		release_focus()


func _on_focus_entered() -> void:
	Bus.location_selected.emit(self)


func _on_focus_exited() -> void:
	Bus.location_deselected.emit(self)
