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
var connections: Array[Connection]
var connected_locations: Array[Location]


func is_connected_to_location(location: Location) -> bool:
	return location in connected_locations


func get_connection_to_location(location: Location) -> Connection:
	for connection: Connection in connections:
		if location in [connection.a, connection.b]:
			return connection
	return null
