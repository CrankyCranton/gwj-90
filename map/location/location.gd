class_name Location extends TextureButton


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
