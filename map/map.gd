class_name Map extends TileMapLayer


@export var connect_distance := 96.0


func _ready() -> void:
	 # IDK why, but this wurks while waiting a frame doesn't :P
	await get_tree().create_timer(0.0).timeout
	generate_connections()


func generate_connections() -> void:
	var locations: Array[Node] = get_tree().get_nodes_in_group(&"locations")
	var predecessors: Array[Location] = []
	for location: Location in locations:
		var nearest_loc: Location = null
		var nearest_dist := INF
		var connections := 0
		for predecessor in predecessors:
			var distance := predecessor.position.distance_to(location.position)
			# The check for null here isn't necessary, but makes it more full-proof.
			# Can be removed for performance if it loops a gazillion times or smth
			if nearest_loc == null or distance < nearest_dist:
				nearest_loc = predecessor
				nearest_dist = distance
			if distance <= connect_distance:
				create_connection(location, predecessor)
				connections += 1

		# Make sure there's at least 1 connection.
		# The null check is for the first location, when there won't be anything to connect to
		if nearest_loc != null and connections <= 0:
			create_connection(location, nearest_loc)
		predecessors.append(location)


func create_connection(a: Location, b: Location) -> void:
	const CONNECTION := preload("res://map/connection/connection.tscn")
	var connection: Line2D = CONNECTION.instantiate()
	connection.add_point(a.position)
	connection.add_point(b.position)
	add_child(connection)
